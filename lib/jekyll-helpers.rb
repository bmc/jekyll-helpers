# Rake tasks and helpers for Jekyll.
#
# Use the following (at the top of your Rakefile) to install the tasks:
#
#    JekyllHelpers::Tasks.new.install do |config|
#        # set configuration here; see below
#    end

require 'fssm'
require 'fileutils'

module JekyllHelpers
  class Tasks
    include Rake::DSL

    def install
      @config = TasksConfig.new
      yield @config if block_given?

      @less_util = LessUtil.new(@config)

      make_less_css_rules
      make_less_watcher
    end

    private

    def make_less_css_rules

      glob_pattern = "#{@config.less_dir}/**/#{@config.less_file_pattern}"
      less_files = Dir.glob glob_pattern
      css_files  = less_files.map do |lf|
        # Strip the less directory from the beginning. Then, add the CSS
        # directory and change the extension.
        s1 = lf.sub @config.less_dir, ""
        s2 = "#{@config.css_dir}#{s1}"
        s2.sub /\.less$/, ".css"
      end

      # Make a task (within the namespace) for generating all the CSS files.
      namespace :jekyll_helpers do
        desc "Make all the out of date CSS files from their LESS counterparts."
        task :css => css_files
      end

      # Make a task for each less -> css file
      for less, css in less_files.zip(css_files)
        desc css
        file css => [less] do
          @less_util.less_to_css less, css
        end
      end
    end

    def make_less_watcher
      desc "Run this task to watch all LESS files for changes."
      namespace :jekyll_helpers do
        task :watch_less do
          # These instance variables don't appear to cross the fork boundary.
          # However, if we capture them in local variables, we can reference
          # them via the locals from within the fork block.
          cfg       = @config
          less_util = @less_util

          puts "Watching #{cfg.less_dir} for changes: #{cfg.less_file_pattern}"
          fork do

            FSSM.monitor(cfg.less_dir, cfg.less_file_pattern) do
              update { |base, rel| less_util.rebuild_from_watch base, rel }
              create { |base, rel| less_util.rebuild_from_watch base, rel }
              delete { |base, rel| less_util.rebuild_from_watch base, rel }
            end
          end
        end
      end
    end


  end

  class TasksConfig
    attr_accessor :less_dir, :css_dir, :less_file_pattern, :less_compress

    def initialize
      @less_dir          = 'less'
      @css_dir           = 'stylesheets'
      @less_file_pattern = '[^_]*.less'
      @less_compress     = false
    end
  end

  class LessUtil
    def initialize(tasks_config)
      @tasks_config = tasks_config
    end

    def rebuild_from_watch(base, relative)
      less_path = File.join(base, relative)
      name = File.basename(less_path).sub(/\.less$/, '.css')
      css_path = File.join(File.absolute_path(@tasks_config.css_dir), name)
      begin
        less_to_css less_path, css_path
      rescue Exception => ex
      end
    end

    def less_to_css(less_path, css_path)
      sh "lessc #{less_path} #{css_path}"
      if @tasks_config.compress
        min_path = css_path.sub(/\.css$/, ".min.css")
        sh "lessc --compress #{less_path} #{min_path}"
      end
    end

    private
   
    def sh(command, *args)
      cmd = command + args.join(' ')
      puts "+ #{cmd}"
      unless system cmd
        raise "'#{cmd}' failed."
      end
    end

  end

end
