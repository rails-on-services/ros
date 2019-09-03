$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
# require "organization/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "ros-organization"
  spec.version     = '0.1.0'
  spec.authors     = ["Write your name"]
  spec.email       = ["Write your email address"]
  # spec.homepage    = "TODO"
  spec.summary     = "Summary of Organization."
  spec.description = "Description of Organization."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '~> 6.0.0.rc2'
  spec.add_dependency 'ros-core', '~> 0.1.0'
  spec.add_dependency 'ros_sdk', '~> 0.1.0'

  # spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'shoulda-matchers'
end
