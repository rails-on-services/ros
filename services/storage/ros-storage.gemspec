$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
# require "storage/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "ros-storage"
  spec.version     = '0.1.0'
  spec.authors     = ['Robert Roach']
  spec.email       = ['rjayroach@gmail.com']
  spec.homepage    = 'https://github.com/rails-on-services'
  spec.summary     = "Manages uploads and downloads of files via UI and SFTP"
  spec.description = "Processes CSV files, notifies other services when new files are available"
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
  spec.add_dependency 'shoryuken'
  spec.add_dependency 'aws-sdk-sqs'
  spec.add_dependency 'net-sftp'

  spec.add_development_dependency "pg"
end
