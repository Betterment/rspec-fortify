# frozen_string_literal: true

require 'English'
require File.expand_path('lib/rspec/fortify/version', __dir__)

Gem::Specification.new do |spec|
  spec.authors       = ['Yusuke Mito', 'Michael Glass', 'Devin Burnette']
  spec.email         = ['devin@betterment.com']
  spec.description   = 'retry intermittently failing rspec examples'
  spec.summary       = 'retry intermittently failing rspec examples'
  spec.homepage      = 'https://github.com/Betterment/rspec-fortify'
  spec.license       = 'MIT'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = []
  spec.name          = 'rspec-fortify'
  spec.require_paths = ['lib']
  spec.version       = RSpec::Fortify::VERSION
  spec.required_ruby_version = '>= 3.0'
  spec.add_runtime_dependency 'rspec-core', '>3.9'
end
