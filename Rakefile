#                                                                 -*- ruby -*-
require 'rubygems'
require 'jekyll-helpers'

include JekyllHelpers

task :run do
  pid = watch_less do |w|
    w.css_dir = 'tmp/css'
    w.less_dir = 'tmp/less'
    w.compress = true
  end
  Process.wait pid
end
