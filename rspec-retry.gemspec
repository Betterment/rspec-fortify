# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rspec/fortify/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Yusuke Mito', 'Michael Glass', 'Devin Burnette']
  gem.email         = ["devin@betterment.com"]
  gem.description   = %q{retry intermittently failing rspec examples}
  gem.summary       = %q{retry intermittently failing rspec examples}
  gem.homepage      = "https://github.com/Betterment/rspec-fortify"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = []
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rspec-fortify"
  gem.require_paths = ["lib"]
  gem.version       = RSpec::Fortify::VERSION
  gem.add_runtime_dependency(%{rspec-core}, '>3.9')
  gem.add_development_dependency %q{appraisal}
  gem.add_development_dependency %q{rspec}
end
