# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ds/version'

Gem::Specification.new do |spec|
  spec.name          = 'mdg'
  spec.version       = Ds::VERSION
  spec.authors       = ['Yuta Hasada']
  spec.email         = ['usgitan@gmail.com']

  spec.summary       = 'My Done Graph'
  spec.description   = 'My Done Graph'
  spec.homepage      = 'https://github.com/yuta17/mdg'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('**/*').select { |path| !(path =~ /^doc |^pkg/) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 3.2.0'
  spec.add_dependency 'sqlite3', '~> 1.3.0'
  spec.add_dependency 'sinatra', '~> 1.4.0'
  spec.add_dependency 'haml', '~> 4.0.0'
  spec.add_dependency 'gruff'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'pry'
end
