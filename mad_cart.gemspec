# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mad_cart/version'

Gem::Specification.new do |spec|
  spec.name          = "mad_cart"
  spec.version       = MadCart::VERSION
  spec.authors       = ["Marc Heiligers", "Stuart Corbishley", "Nic Young"]
  spec.email         = [""]
  spec.description   = %q{Provides a unified api for various e-commerce merchants.}
  spec.summary       = %q{Allows communication with various e-commerce merchants such as BigCommerce and Etsy through a single gem. Extensible to allow the easy addition of merchants and functionality.}
  spec.homepage      = "https://github.com/madmimi/mad_cart"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'json', '~> 1.7.7'
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "faraday"
  spec.add_development_dependency "vcr", "~> 1.0"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "etsy", "0.2.1"
  spec.add_development_dependency 'money'
  spec.add_development_dependency 'activesupport', "~> 3.2"
end
