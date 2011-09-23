$LOAD_PATH.unshift 'lib'
require 'brocade/version'

Gem::Specification.new do |s|
  s.name         = 'brocade'
  s.version      = Brocade::VERSION
  s.summary      = 'Generates barcodes for Rails ActiveRecord models.'
  s.description  = s.summary
  s.homepage     = 'http://github.com/airblade/brocade'
  s.authors      = ['Andy Stewart']
  s.email        = 'boss@airbladesoftware.com'
  s.files        = %w[ LICENSE README.md Rakefile brocade.gemspec ]
  s.files       += %w[ init.rb install.rb ]
  s.files       += Dir.glob("lib/**/*")
  s.test_files   = Dir.glob("test/**/*")
  s.require_path = 'lib'

  s.add_dependency 'barby',      '~> 0.5'
  s.add_dependency 'chunky_png', '~> 1.2'
end

