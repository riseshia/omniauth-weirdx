# coding: utf-8
require File.expand_path('../lib/omniauth-weirdx/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-slack'
  spec.version       = Omniauth::Weirdx::VERSION
  spec.authors       = ['shia']
  spec.email         = ['rise.shia@gmail.com']
  spec.description   = 'OmniAuth strategy for Weirdx'
  spec.summary       = 'OmniAuth strategy for Weirdx'
  spec.homepage      = 'https://github.com/riseshia/omniauth-weirdx.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'omniauth-oauth2', '~> 1.3.1'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
end
