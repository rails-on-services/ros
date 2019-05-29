# frozen_string_literal: true

# Modify a new Rails app to become a Ros service
# NOTE: Dir.pwd returns dummy_path while destination_root returns the app path
def source_paths; Array(super) + [File.expand_path(File.dirname(__FILE__))] end

require_relative 'profile'
@profile = Profile.new(name, self, options.dup)

apply('gems.rb')
apply('pg.rb')
# Create Engine's namespaced classes
apply('engine_classes.rb') if @profile.is_engine?
# Modify spec/dummy or app Base Classes
apply('app_classes.rb') if @profile.is_engine?
apply('initializers.rb')
apply('routes.rb')
apply('models.rb')
# Write seed files for tenants, etc
apply('seeds.rb')

append_to_file 'README.md' do <<-RUBY

## Documentation
"[Rails on Services Guides](https://guides.rails-on-services.org)"
RUBY
end

create_file 'doc/open_api.yml' do <<-RUBY
---
api_docs:
  info:
    description: 'Service description'
    version: '0.1.0'
  server:
    description: 'server description'
RUBY
end

create_file 'config/environment.rb'

create_file 'config/spring.rb' do <<-RUBY
Spring.application_root = './spec/dummy'
RUBY
end

create_file 'config/sidekiq.yml' do <<-RUBY
---
:queues:
  - #{@profile.service_name}_platform_producer_events
  - #{@profile.service_name}_platform_consumer_events
  - #{@profile.service_name}_tenant_producer_events
  - #{@profile.service_name}_tenant_consumer_events
RUBY
end

# copy_file 'defaults/files/Procfile', 'Procfile'
# template 'defaults/files/tmuxinator.yml', '.tmuxinator.yml'
