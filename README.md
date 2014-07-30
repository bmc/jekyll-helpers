# Jekyll Helpers

This package is basically a dumping ground for common Rake helpers I use when
building various static sites with Jekyll.

I use it, but that doesn't necessarily means it's useful for your needs.
It's a work in progress. Feel free to partake, but _caveat emptor_.

## Usage

The gem provides a `JekyllHelpers` module with various Rake tasks.

### Installing and configuring the tasks

At the top of your Rakefile, add this block:

```ruby
require `rubygems`
require `jekyll-helpers`

JekyllHelpers::Tasks.new.install do |config|
  config.less_dir          = 'less'        # directory containing LESS files
  config.css_dir           = 'stylesheets' # directory where CSS should go
  config.less_compress     = true          # whether to make compressed CSS, too
  config.less_file_pattern = '[^_]*.less'  # file pattern to match LESS files
end
```

The values shown above are the defaults. The block is _not_ required.

### The tasks you get

After task installation, your Rakefile will have the following tasks:

* `jekyll_helpers:css` - generate all CSS files that are out of date
  with respect to their LESS sources.

* individual LESS-to-CSS file rules - generated from the configuration

* `jekyll_helpers:watch_less` - A task that forks a subprocess to watch
  and rebuild CSS files as their LESS sources change. Example uses:
  
```ruby
# We're only going to wait on LESS files.
task :run => 'jekyll_helpers:watch_less' do
  Process.wait # wait until it finishes
end
```

```ruby
# Wait on LESS files ourselves. Let Jekyll handle everything else.
task :run => 'jekyll_helpers:watch_less' do
  sh 'jekyll server --watch"
end
```
