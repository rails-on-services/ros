# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |spec|
  spec.name        = 'cnfs-iam'
  spec.version     = '0.0.1.alpha'
  spec.authors     = ['Robert Roach', 'Rui Baltazar']
  spec.email       = ['rjayroach@gmail.com', 'rui.p.baltazar@gmail.com']
  spec.homepage    = 'http://guides.rails-on-services.org/'
  spec.summary     = 'Provides Identity and Access Management for the Ros Platform'
  spec.description = 'Facilities to manage Users, Groups and Roles permission to Platform Resources'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'bcrypt', '~> 3.1.12'
  spec.add_dependency 'rails', '~> 6.0.2.1'
  spec.add_dependency 'devise', '~> 4.7.1'
  spec.add_dependency 'cnfs-core', '= 0.0.1alpha'
  spec.add_dependency 'cnfs_sdk', '= 0.0.1alpha'
end
