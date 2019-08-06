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

  spec.add_dependency 'rails', '~> 6.0.0.rc2'
  spec.add_dependency 'jsonapi-resources', '0.9.5'
  spec.add_dependency 'jsonapi-authorization', '1.0.0'
  spec.add_dependency 'warden', '1.2.8'
  spec.add_dependency 'jwt', '2.1.0'
  spec.add_dependency 'pry-rails', '0.3.9'
  # spec.add_dependency 'pry-remote'
  spec.add_dependency 'apartment', '2.2.0'
  spec.add_dependency 'grpc', '1.18.0'
  spec.add_dependency 'prometheus_exporter', '0.4.5'
  spec.add_dependency 'sidekiq', '5.2.5'
  spec.add_dependency 'seedbank', '0.5.0'
  spec.add_dependency 'sentry-raven', '2.9.0'
  spec.add_dependency 'attr_encrypted', '~> 3.1.0'
  spec.add_dependency 'zero-rails_openapi', '2.1.0'
  spec.add_dependency 'config', '1.7.1'
  spec.add_dependency 'rack-cors'
  spec.add_dependency 'rack-fluentd-logger', '0.1.4'
  spec.add_dependency 'avro_turf', '~> 0.9.0'
  # spec.add_dependency 'ros_sdk', '~> 0.1.0'

  spec.add_dependency 'aws-sdk-s3'

  # spec.add_development_dependency 'sqlite3', '~> 1.3'
end
