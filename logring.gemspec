# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logring/version'

Gem::Specification.new do |spec|
  spec.name          = "logring"
  spec.version       = Logring::VERSION
  spec.authors       = ["mose"]
  spec.email         = ["mose@mose.com"]
  spec.summary       = %q{One logring to rule them all.}
  spec.description   = %q{Tool for gathering log reports from various servers.}
  spec.homepage      = "https://github.com/eduvo/logring"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "request-log-analyzer"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
