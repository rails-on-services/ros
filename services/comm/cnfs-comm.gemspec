# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |spec|
  spec.name        = 'cnfs-comm'
  spec.version     = '0.0.1.alpha'
  spec.authors     = ['Robert Roach', 'Rui Baltazar']
  spec.email       = ['rjayroach@gmail.com', 'rui.p.baltazar@gmail.com']
  spec.homepage    = 'http://guides.rails-on-services.org/'
  spec.summary     = 'Provides communication tools, e.g. Twilio to the CNFS Platform'
  spec.description = '3rd party communication services can be invoked by other services per tenant'
  spec.license     = 'MIT'
  spec.required_ruby_version = ['> 2.6.0', '< 2.7' ]

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'aasm', '~> 5.0.6'
  spec.add_dependency 'aws-sdk-sns', '~> 1.21.0'
  spec.add_dependency 'cnfs-core', '= 0.0.1alpha'
  spec.add_dependency 'cnfs_sdk', '= 0.0.1alpha'
  spec.add_dependency 'rails', '~> 6.0.2.1'
  spec.add_dependency 'twilio-ruby', '~> 5.31.0'
end
