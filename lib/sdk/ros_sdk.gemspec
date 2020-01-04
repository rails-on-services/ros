# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'ros_sdk'
  spec.version       = '0.1.0'
  spec.authors       = ['Robert Roach']
  spec.email         = ['rjayroach@gmail.com']

  spec.summary       = 'Loads JSONAPI based models to connect with remote RESTful services'
  spec.description   = 'Authenticate and connect to remote services via REST'
  spec.homepage      = 'https://github.com/rails-on-services'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files = Dir["{bin,lib}/**/*", 'ros_sdk.gemspec', 'settings.yml', 'Rakefile', 'README.md']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activemodel', '6.0.2.1'
  spec.add_dependency 'activesupport', '6.0.2.1'
  spec.add_dependency 'config', '1.7.1'
  spec.add_dependency 'globalid', '0.4.2'
  spec.add_dependency 'inifile', '3.0.0'
  spec.add_dependency 'json_api_client', '1.15.0'
  spec.add_dependency 'jwt', '2.2.1'
  spec.add_dependency 'pry', '0.12.2'

  spec.add_development_dependency 'awesome_print', '1.8.0'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.0'
end
