# frozen_string_literal: true

module Storage
  class Engine < ::Rails::Engine
    config.generators.api_only = true
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    initializer :shoryuken do |app|
      queue_url = 'http://localstack:4576' # /queue/#{queue_name}"
      # queue_name = "#{Settings.service.name}_platform_consumer_events"
      queue_name = 'storage_platform_consumer_events'

      Rails.configuration.x.client = Aws::SQS::Client.new({
        access_key_id: 'hello',
        secret_access_key: 'test',
        region: 'ap-southeast-1',
        endpoint: queue_url,
        verify_checksums: false
      })

      # queue_url = "http://localstack:4576/queue/#{queue_name}"
      # Rails.configuration.x.client.create_queue({ queue_name: queue_name })

      # binding.pry
      # Shoryuken.configure_server { |config| config.sqs_client = Rails.configuration.x.client }
    end

    # Adds this gem's db/migrations path to the enclosing application's migraations_path array
    # if the gem has been included in an application, i.e. it is not running in the dummy app
    # https://github.com/rails/rails/issues/22261
    initializer :append_migrations do |app|
      config.paths['db/migrate'].expanded.each do |expanded_path|
        app.config.paths['db/migrate'] << expanded_path
        ActiveRecord::Migrator.migrations_paths << expanded_path
      end unless app.config.paths['db/migrate'].first.include? 'spec/dummy'
    end

    initializer :console_methods do |app|
      Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
      Ros.config.model_paths += config.paths['app/models'].expanded
    end if Rails.env.development?

    initializer :service_values do |app|
      name = self.class.parent.name.demodulize.underscore
      Settings.prepend_source!({ service: { name: name, policy_name: name.capitalize } })
    end
  end
end
