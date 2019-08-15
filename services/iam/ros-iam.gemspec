$:.push File.expand_path('lib', __dir__)

Gem::Specification.new do |spec|
  spec.name        = 'ros-iam'
  spec.version     = '0.1.0'
  spec.authors     = ['Robert Roach']
  spec.email       = ['rjayroach@gmail.com']
  spec.homepage    = 'https://github.com/rails-on-services'
  spec.summary     = 'Provides Identity and Access Management for the Ros Platform'
  spec.description = 'Facilities to manage Users, Groups and Roles permission to Platform Resources'
  spec.license     = 'MIT'

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'rails', '~> 6.0.0.rc2'
  spec.add_dependency 'bcrypt', '~> 3.1.12'
  # spec.add_dependency 'devise-jwt', '~> 0.5.8'
  spec.add_dependency 'devise'
  spec.add_dependency 'ros-core', '~> 0.1.0'
  spec.add_dependency 'ros_sdk', '~> 0.1.0'

  # spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'faker'
end
