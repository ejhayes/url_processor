# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'url_processor/version'

Gem::Specification.new do |spec|
  spec.name          = "url_processor"
  spec.version       = UrlProcessor::VERSION
  spec.authors       = ["Eric Hayes"]
  spec.email         = ["eric@deployfx.com"]
  spec.summary       = %q{Fast and reliable link checker.}
  spec.description   = %q{Fast and easy way to validate tons of urls without locking up your system or eating up too much memory.}
  spec.homepage      = "https://github.com/ejhayes/url_processor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
