# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'solidus_lograge/version'

Gem::Specification.new do |spec|
  spec.name          = "solidus_lograge"
  spec.version       = SolidusLograge::VERSION
  spec.authors       = ["Brian Buchalter"]
  spec.email         = ["bal711@gmail.com"]

  spec.summary       = %{Single-line, JSON-formatted logs for Solidus.}
  spec.description   = %{A set of sane defaults for the Solidus sample store.}
  spec.homepage      = "https://github.com/bbuchalter/solidus_lograge"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "solidus", ['>= 1.0', '< 3']
  spec.add_dependency "lograge", '~> 0.5'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails", "~> 3"
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'capybara'
end
