# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'ros/cognito/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'cnfs-cognito'
  spec.version     = Ros::Cognito::VERSION
  spec.authors     = ['Robert Roach', 'Rui Baltazar']
  spec.email       = ['rjayroach@gmail.com', 'rui.p.baltazar@gmail.com']
  spec.homepage    = 'http://guides.rails-on-services.org/'
  spec.summary     = ': Summary of Ros::Cognito.'
  spec.description = ': Description of Ros::Cognito.'
  spec.license     = 'MIT'
  spec.required_ruby_version = ['> 2.6.0', '< 2.7' ]

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '~> 6.0.2.1'
  spec.add_dependency 'cnfs-core', '= 0.0.1alpha'
  spec.add_dependency 'cnfs_sdk', '= 0.0.1alpha'
end