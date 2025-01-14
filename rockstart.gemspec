# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "rockstart/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rockstart"
  spec.version     = Rockstart::VERSION
  spec.authors     = ["Ben Morrall"]
  spec.email       = ["bemo56@hotmail.com"]
  spec.homepage    = "https://github.com/bmorrall/rockstart"
  spec.summary     = "Generators for getting Rails Ready to Rock!"
  spec.description = "A collection of generators to rapidly start and update ready-to-run Rails Applications."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.4.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "< 6.2"

  spec.add_development_dependency "rubocop", "~> 0.80.1"
  spec.add_development_dependency "sqlite3", "~> 1.4.2"
end
