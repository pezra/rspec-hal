# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/hal/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-hal"
  spec.version       = RSpec::Hal::VERSION
  spec.authors       = ["Peter Williams"]
  spec.email         = ["pezra@barelyenough.org"]
  spec.summary       = %q{Matchers and helpers for specing HAL documents.}
  spec.homepage      = "http://github.com/pezra/rspec-hal"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"

  spec.add_runtime_dependency "rspec", ">= 2.0", "< 4.0.0.pre"
  spec.add_runtime_dependency "hal-client", "> 2.4"
end
