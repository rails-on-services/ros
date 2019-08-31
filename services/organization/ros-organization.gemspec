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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.0.rc2"

  spec.add_development_dependency "pg"
end
