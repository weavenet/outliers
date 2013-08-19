# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'outliers/version'

Gem::Specification.new do |spec|
  spec.name          = "outliers"
  spec.version       = Outliers::VERSION
  spec.authors       = ["Brett Weaver"]
  spec.email         = ["brett@weav.net"]
  spec.description   = %q{Configuraiton verification framework.}
  spec.summary       = %q{Configuration verification framework.}
  spec.homepage      = "https://github.com/brettweavnet/outliers"
  spec.license       = "Apache2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1.0"
  spec.add_development_dependency "rspec", "~> 2.13.0"

  spec.add_runtime_dependency "aws-sdk", "1.14.1"
end
