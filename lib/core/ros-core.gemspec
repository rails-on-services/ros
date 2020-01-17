$:.push File.expand_path("lib", __dir__)

# require 'ros/core/version'

Gem::Specification.new do |spec|
  spec.name        = 'ros-core'
  spec.version     = '0.1.0' # Ros::Core::VERSION
  spec.authors     = ['Robert Roach']
  spec.email       = ['rjayroach@gmail.com']
  spec.homepage    = 'https://github.com/rails-on-services'
  spec.summary     = 'Provides common support services to Rails on Services based Projects'
  spec.description = 'Base controller, model, resource and policy classes; authentication with JWT, per request tenant selection, exception reporting'
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*", 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'ros-apartment', '2.3.0'
  spec.add_dependency 'ros-apartment-sidekiq', '1.2.0'
  spec.add_dependency 'attr_encrypted', '~> 3.1.0'
  spec.add_dependency 'avro_turf', '~> 0.9.0'
  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'bullet', '~> 6.1.0'
  spec.add_dependency 'config', '1.7.1'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'hashids', '1.0.5'
  spec.add_dependency 'grpc', '1.23.0'
  spec.add_dependency 'json_schemer', '0.2.6'
  spec.add_dependency 'jsonapi-authorization', '3.0.1'
  spec.add_dependency 'jsonapi-resources', '~> 0.9.10'
  spec.add_dependency 'jwt', '2.2.1'
  spec.add_dependency 'prometheus_exporter', '0.4.13'
  spec.add_dependency 'pry-rails', '0.3.9'
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'rack-fluentd-logger', '0.1.5'
  spec.add_dependency 'rails', '~> 6.0.2.1'
  spec.add_dependency 'rufus-scheduler', '~> 3.6.0'
  spec.add_dependency 'seedbank', '0.5.0'
  spec.add_dependency 'sentry-raven', '2.11.1'
  spec.add_dependency 'sidekiq', '6.0.0'
  spec.add_dependency 'trailblazer-activity', '~> 0.10.0'
  spec.add_dependency 'trailblazer-activity-dsl-linear', '~> 0.2.1'
  spec.add_dependency 'warden', '1.2.8'
  spec.add_dependency 'zero-rails_openapi', '2.1.0'
  # spec.add_dependency 'ros_sdk', '~> 0.1.0'

  spec.add_development_dependency 'factory_bot_rails', '~> 5.0.2'
  spec.add_development_dependency 'rspec-rails', '~> 3.8.2'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  spec.add_development_dependency 'trailblazer-developer'
end
