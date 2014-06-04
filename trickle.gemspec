# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trickle/version'

Gem::Specification.new do |spec|
  spec.name          = "trickle"
  spec.version       = Trickle::VERSION
  spec.authors       = ["Kale Davis"]
  spec.email         = ["kale@kaledavis.com"]
  spec.summary       = %q(Run commands specified within files at different rates)
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/kale/trickle"
  spec.license       = "MIT"

  spec.bindir = 'bin'
  spec.executables = %w[trickle]
  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
end
