# frozen_string_literal: true

module Storage
  class Engine < ::Rails::Engine
    config.generators.api_only = true
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    initializer 'service.storage_thing' do |_app|
      ActiveStorage::Service.module_eval { attr_writer :bucket }
      ActiveStorage::Service.class_eval { include Storage::Methods }
    end

    initializer 'service.set_platform_config', before: 'ros_core.load_platform_config' do |_app|
      settings_path = root.join('config/settings.yml')
      Settings.prepend_source!(settings_path) if File.exist? settings_path
      name = self.class.module_parent.name.demodulize.underscore
      Settings.prepend_source!(service: { name: name, policy_name: name.capitalize })
    end

    initializer 'service.initialize_infra_services', after: 'ros_core.initialize_infra_services' do |_app|
      # AWS SQS Workers
      if defined?(Shoryuken)
        Shoryuken.configure_server do |config|
          config.sqs_client = Rails.configuration.x.infra.resources.mq.primary.client
        end
        Rails.configuration.x.infra.resources.storage.primary.add_queue_notification(
          queue_name: Rails.configuration.x.infra.resources.mq.primary.name,
          events: ['s3:ObjectCreated:*'],
          filter_rules: [{ name: 'prefix', value: 'storage/sftp/home' }, { name: 'suffix', value: '.csv' }]
        )
        Rails.configuration.x.infra.resources.storage.primary.enable_notifications
        # elsif defined?(GcpQueueWorker)
      end
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

    initializer 'service.set_factory_paths', after: 'ros_core.set_factory_paths' do
      if defined?(FactoryBot) && !Rails.env.production?
        FactoryBot.definition_file_paths.prepend(Pathname.new(__FILE__).join('../../../spec/factories'))
      end
    end

    initializer 'service.configure_event_logging' do |_app|
      if Settings.event_logging.enabled
        Settings.event_logging.config.schemas_path = root.join(Settings.event_logging.config.schemas_path)
      end
    end
  end
end
