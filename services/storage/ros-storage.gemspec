# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'ros/storage/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'cnfs-storage'
  spec.version     = Ros::Storage::VERSION
  spec.authors     = ['Robert Roach', 'Rui Baltazar']
  spec.email       = ['rjayroach@gmail.com', 'rui.p.baltazar@gmail.com']
  spec.homepage    = 'http://guides.rails-on-services.org/'
  spec.summary     = 'Manages uploads and downloads of files via UI and SFTP'
  spec.description = 'Processes CSV files, notifies other services when new files are available'
  spec.license     = 'MIT'
  spec.required_ruby_version = ['> 2.6.0', '< 2.7' ]

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'aws-sdk-sqs', '~> 1.23.1'
  spec.add_dependency 'cnfs-core', '= 0.0.1alpha'
  spec.add_dependency 'cnfs_sdk', '= 0.0.1alpha'
  spec.add_dependency 'net-sftp', '~> 2.1.2'
  spec.add_dependency 'rails', '~> 6.0.2.1'
  spec.add_dependency 'shoryuken', '~> 5.0.2'
end
