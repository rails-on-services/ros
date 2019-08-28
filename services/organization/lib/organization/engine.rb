# frozen_string_literal: true

module Organization
  class Engine < ::Rails::Engine
    config.generators.api_only = true
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
    initializer 'service.set_platform_config', before: 'ros_core.load_platform_config' do |_app|
      settings_path = root.join('config/settings.yml')
      Settings.prepend_source!(settings_path) if File.exist? settings_path
      name = self.class.parent.name.demodulize.underscore
      Settings.prepend_source!({ service: { name: name, policy_name: name.capitalize } })
    end
    initializer 'service.initialize_infra_services', after: 'ros_core.initialize_infra_services' do |app|
    end
    # Adds this gem's db/migrations path to the enclosing application's migraations_path array
    # if the gem has been included in an application, i.e. it is not running in the dummy app
    # https://github.com/rails/rails/issues/22261
    initializer 'service.configure_migrations' do |app|
      unless Rails.root.to_s.end_with?('spec/dummy')
      # unless app.config.paths['db/migrate'].first.include? 'spec/dummy'
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
          ActiveRecord::Migrator.migrations_paths << expanded_path
        end
      end
    end
    initializer 'service.configure_console_methods', before: 'ros_core.configure_console_methods' do |_app|
      if Rails.env.development? and Rails.const_defined?('Console')
        Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
        Ros.config.model_paths += config.paths['app/models'].expanded
      end
    end
  end
end
