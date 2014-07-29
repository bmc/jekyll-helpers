# Creates tasks in the ":jekyll_helpers" namespace.

require 'fssm'
require 'fileutils'

module JekyllHelpers
  module Util
    include FileUtils

    def less_to_css(less_path, css_path, compress_also=false)
      sh "lessc #{less_path} #{css_path}"
      if compress_also
        min_path = css_path.sub(/\.css$/, ".min.css")
        sh "lessc --compress #{less_path} #{min_path}"
      end
    end

    def sh(command, *args)
      cmd = command + args.join(' ')
      puts "+ #{cmd}"
      unless system cmd
        raise "'#{cmd}' failed."
      end
    end
  end

  class JekyllHelpersTasks
    include Rake::DSL
    include Util

    def install_tasks
      namespace :jekyll_helpers do

        desc "Test"
        task :test do
          puts 'test'
        end
      end
    end

  end

  # Watch a directory full of LESS files and convert them to CSS when they
  # change, using the lessc command (which is presumed to be in the path).
  # The function yields configuration object to a supplied block, allowing
  # the following to be set:
  #
  # cfg.less_dir       - the directory containing the LESS files. Defaults
  #                      to "less"
  # cfg.css_dir        - the directory containing the LESS files. Defaults 
  #                      to "css"
  # cfg.file_pattern   - a glob pattern to match the LESS files.
  #                      Defaults to "*.less"
  # cfg.compress       - true to generate minified CSS, as well as regular CSS.
  #                      Defaults to false.
  # cfg.action         - a Proc (or lambda) to call with each file to rebuild.
  #                      Default: an internal Proc is used. The Proc should
  #                      take three parameters: The path to the LESS file,
  #                      the path to the corresponding CSS file to build,
  #                      and a boolean flag indicating whether compression
  #                      should also be done.
  # cfg.abort_on_error - true to throw an exception on LESS compilation error.
  #                      Default: false
  #
  # Returns the process ID of the monitor subprocess (i.e., the result of a
  # fork() call).
  def watch_less
    cfg = LessWatcherConfig.new
    yield cfg
    puts "Watching #{cfg.less_dir} for LESS updates to: #{cfg.file_pattern}"

    def rebuild(base, relative, cfg)
      less_path = File.join(base, relative)
      name = File.basename(less_path).sub(/\.less$/, '.css')
      css_path = File.join(File.absolute_path(cfg.css_dir), name)
      begin
        cfg.action.call(less_path, css_path, cfg.compress)
      rescue Exception => ex
        raise if cfg.abort_on_error
      end
    end

    fork do
      FSSM.monitor(cfg.less_dir, cfg.file_pattern) do
        update { |base, relative| rebuild base, relative, cfg }
        create { |base, relative| rebuild base, relative, cfg }
        delete { |base, relative| rebuild base, relative, cfg }
      end
    end
  end

  class LessWatcherConfig
    include Util

    attr_accessor :less_dir, :css_dir, :file_pattern, :compress, :action,
                  :abort_on_error

    def initialize
      @less_dir       = "less"
      @css_dir        = "css"
      @file_pattern   = "*.less"
      @compress       = false
      @action         = method(:less_to_css)
      @abort_on_error = false
    end

    def to_s
      "<LessWatcherConfig: @less_dir=#{@less_dir}, @css_dir=#{@css_dir}>"
    end

  end

end

JekyllHelpers::JekyllHelpersTasks.new.install_tasks
