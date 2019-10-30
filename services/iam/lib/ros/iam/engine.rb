# frozen_string_literal: true

module Ros
  module Iam
    class Engine < ::Rails::Engine
      config.generators.api_only = true
      config.generators do |g|
        g.test_framework :rspec, fixture: true
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end

      initializer 'service.set_platform_config', before: 'ros_core.load_platform_config' do |_app|
        settings_path = root.join('config/settings.yml')
        Settings.prepend_source!(settings_path) if File.exist? settings_path
        name = self.class.module_parent.name.demodulize.underscore
        Settings.prepend_source!(service: { name: name, policy_name: name.capitalize })
      end

      # Adds this gem's db/migrations path to the enclosing application's migraations_path array
      # if the gem has been included in an application, i.e. it is not running in the dummy app
      # https://github.com/rails/rails/issues/22261
      initializer 'service.configure_migrations' do |app|
        unless Rails.root.to_s.end_with?('spec/dummy')
          config.paths['db/migrate'].expanded.each do |expanded_path|
            app.config.paths['db/migrate'] << expanded_path
            ActiveRecord::Migrator.migrations_paths << expanded_path
          end
        end
      end

      initializer 'service.set_factory_paths', before: 'ros_core.set_factory_paths' do
        if defined?(FactoryBot) && !Rails.env.production?
          FactoryBot.definition_file_paths.prepend(Pathname.new(__FILE__).join('../../../../spec/factories'))
        end
      end

      initializer 'service.configure_event_logging' do |_app|
        if Settings.event_logging.enabled
          Settings.event_logging.config.schemas_path = root.join(Settings.event_logging.config.schemas_path)
        end
      end

      # initializer 'service.initialize_infra_services', after: 'ros_core.initialize_infra_services' do |app|
      # end

      initializer 'service.configure_console_methods', before: 'ros_core.configure_console_methods' do |_app|
        if Rails.env.development? && !Rails.const_defined?('Server') && File.exist?('console.rb')
          require_relative 'console'
        end
      end
    end
  end
end
