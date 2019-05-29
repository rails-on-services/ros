# frozen_string_literal: true

insert_into_file @profile.config_file, before: 'require' do <<-RUBY
require 'ros/core'
RUBY
end

# TODO: here might be the issue with spec/dummy migrations
if @profile.is_ros?
  inject_into_file @profile.initializer_file, after: ".api_only = true\n" do <<-RUBY

      # Adds this gem's db/migrations path to the enclosing application's migraations_path array
      # if the gem has been included in an application, i.e. it is not running in the dummy app
      # https://github.com/rails/rails/issues/22261
      initializer :append_migrations do |app|
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
          ActiveRecord::Migrator.migrations_paths << expanded_path
        end unless app.config.paths['db/migrate'].first.include? 'spec/dummy'
      end
RUBY
  end
end

inject_into_file @profile.initializer_file, after: ".api_only = true\n" do <<-RUBY
      initializer :console_methods do |app|
        Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
        Ros.config.model_paths += config.paths['app/models'].expanded
      end if Rails.env.development?
RUBY
end

=begin
if app.ros.service
  inject_into_file initializer_file, after: ".api_only = true\n" do <<-RUBY
    config.after_initialize do
      Settings.service['name'] = '#{app.application_name.gsub('ros-', '')}'
      Settings.service['policy_name'] = '#{app.application_name.gsub('ros-', '').classify}'
    end
RUBY
  end
end
=end

# TODO: Test this with an application like Survey b/c that's not an engine.
inject_into_file @profile.initializer_file, after: ".api_only = true\n" do <<-RUBY
      initializer :service_values do |app|
        name = self.class.parent.name.demodulize.underscore
        Settings.service.name = name # '#{@profile.service_name}'
        Settings.service.policy_name = name.capitalize # '#{@profile.service_name.capitalize}'
      end
RUBY
end
