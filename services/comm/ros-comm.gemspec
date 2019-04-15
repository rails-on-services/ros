# frozen_string_literal: true

$:.push File.expand_path("lib", __dir__)

# require 'ros/comm/version'

Gem::Specification.new do |spec|
  spec.name        = 'ros-comm'
  spec.version     = '0.1.0' # Ros::Comm::VERSION
  spec.authors     = ['Robert Roach']
  spec.email       = ['rjayroach@gmail.com']
  spec.homepage    = 'https://github.com/rails-on-services'
  spec.summary     = 'Provides communication tools, e.g. Twilio to the Ros Platform'
  spec.description = '3rd party communication services can be invoked by other services per tenant'
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '~> 6.0.0.beta3'
  spec.add_dependency 'twilio-ruby'
  spec.add_dependency 'aws-sdk-sns'

  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'faker'
end
