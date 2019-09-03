# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

Gem::Specification.new do |spec|
  spec.name        = 'ros-comm'
  spec.version     = '0.1.0'
  spec.authors     = ['Robert Roach']
  spec.email       = ['rjayroach@gmail.com']
  spec.homepage    = 'https://github.com/rails-on-services'
  spec.summary     = 'Provides communication tools, e.g. Twilio to the Ros Platform'
  spec.description = '3rd party communication services can be invoked by other services per tenant'
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '~> 6.0.0.rc2'
  spec.add_dependency 'twilio-ruby'
  spec.add_dependency 'aws-sdk-sns'
  spec.add_dependency 'ros-core', '~> 0.1.0'
  spec.add_dependency 'ros_sdk', '~> 0.1.0'

  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'shoulda-matchers'
end
