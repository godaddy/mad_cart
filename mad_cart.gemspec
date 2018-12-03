# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mad_cart/version'

Gem::Specification.new do |gem| # rubocop:disable Metrics/BlockLength
  gem.name          = 'mad_cart'
  gem.version       = MadCart::VERSION
  gem.authors       = ['Marc Heiligers', 'Stuart Corbishley', 'Nic Young']
  gem.email         = ['support@madmimi.com']
  gem.description   = 'Provides a unified api for various e-commerce merchants.'
  gem.summary       = 'Allows communication with various e-commerce ' \
                      'merchants such as BigCommerce and Etsy through a ' \
                      'single gem. Extensible to allow the easy addition of ' \
                      'merchants and functionality.'
  gem.homepage      = 'https://github.com/madmimi/mad_cart'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/) # rubocop:disable Style/SpecialGlobalVars, Metrics/LineLength
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'faraday'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'etsy', '0.2.6'
  gem.add_dependency 'money', '~> 6.7'
  gem.add_dependency 'monetize', '~> 1.4'
  gem.add_dependency 'activesupport', '> 4.2'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'json'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'vcr', '2.5.0'
  gem.add_development_dependency 'webmock', '~> 1.11.0'
  gem.add_development_dependency 'simplecov'
end
