#                                                                -*- ruby -*-

Gem::Specification.new do |s|

  s.name             = 'jekyll-helpers'
  s.version          = '0.0.1'
  s.date             = '2014-07-29'
  s.summary          = 'Rake tasks and helpers for use with Jekyll.'
  s.authors          = ['Brian M. Clapper']
  s.license          = 'BSD'
  s.email            = 'bmc@clapper.org'
  s.homepage         = 'https://github.com/bmc/jekyll-helpers'

  s.description      = <<-ENDDESC
This package is basically a dumping ground for common Rake helpers I use when
building various static sites with Jekyll.
ENDDESC

  s.require_paths    = ['lib']

  s.files            = Dir.glob('[A-Z]*')
  s.files           += Dir.glob('*.gemspec')
  s.files           += Dir.glob('lib/**/*')
  s.files           += Dir.glob('rdoc/**/*')

  s.add_runtime_dependency 'fssm', '~> 0.2', '>= 0.2.10'

end


