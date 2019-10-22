# frozen_string_literal: true

module Ros
  module Core
    # rubocop:disable Metrics/ClassLength
    class Engine < ::Rails::Engine
      config.generators.api_only = true
      # TODO: Make this configurable from ros config/platform.yml
      config.active_job.queue_adapter = :sidekiq
      config.generators do |g|
        g.test_framework :rspec, fixture: true
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end

      initializer 'ros_core.sidekiq' do |app|
      end

      # NOTE: ENV vars indicate hierarchy with two underscores '__'
      # export PLATFORM__CREDENTIALS__JWT_ENCRYPTION_KEY='test'
      initializer 'ros_core.set_platform_config' do |_app|
        settings_path = root.join('config/settings')
        # NOTE: Sources are prepended in reverse order, meaning the first prepend is loaded last
        Settings.prepend_source!(credentials: Rails.application.credentials.config)
        Settings.prepend_source!("#{settings_path}.yml")
      end

      initializer 'ros_core.load_platform_config' do |_app|
        # The location of the environment files is the parent services/.env dir
        # This dir is soft linked to the compose directory of the current deployment
        if Ros.host_env.os? && Dir.exist?("#{Ros.root}/services/.env")
          configs = ['platform']
          ary = Settings.instance_variable_get('@config_sources').select do |config|
            config.instance_variable_get('@hash')&.keys&.include?(:service)
          end
          if ary.any? && (service_name = ary.first.hash[:service][:name])
            configs.append(service_name)
          end
          require 'dotenv'
          configs.each do |env_name|
            env_file = "#{Ros.root}/services/.env/#{env_name}.env"
            Dotenv.load(env_file) if File.exist?(env_file)
          end
          # Set ENVs that allow the local server to access compose cluster services
          # TODO: Figure out how core/config/settings.local.yml can override the ENVs
          ENV['PLATFORM__CONNECTION__HOST__HOST'] = 'localhost'
          ENV['PLATFORM__CONNECTION__HOST__FORCE_PATH_STYLE'] = 'true'
          ENV['PLATFORM__REQUEST_LOGGING__ENABLED'] = 'false'
          ENV['PLATFORM__EVENT_LOGGING__ENABLED'] = 'false'
          ENV['RAILS_DATABASE_HOST'] = 'localhost'
          ENV['REDIS_URL'] = 'redis://localhost:6379'
          ENV['PLATFORM__REQUEST_LOGGING__CONFIG__HOST'] = 'localhost'
          ENV['PLATFORM__INFRA__SERVICES__STORAGE__AWS__ENDPOINT'] = 'http://localhost:4572'
          ENV['PLATFORM__INFRA__SERVICES__MQ__AWS__ENDPOINT'] = 'http://localhost:4576'
          ENV['BUCKET_ENDPOINT_URL'] = 'http://localhost:4572'
        end
        Settings.reload!
      end

      initializer 'ros_core.initialize_infra_services' do |_app|
        if Settings.dig(:infra, :services)
          Settings.infra.services.each_pair do |_service, config|
            require "ros/infra/#{config.keys[0]}"
          end
          Rails.configuration.x.infra.resources = ActiveSupport::OrderedOptions.new
          # Settings.infra.resources.each_pair do |service, resources|
          #   Rails.configuration.x.infra.resources[service] = ActiveSupport::OrderedOptions.new
          #   resources.each_pair do |name, config|
          #     next unless config.enabled

          #     Rails.configuration.x.infra.resources[service][name] =
          #       Object.const_get("Ros::Infra::#{config.provider.capitalize}::#{service.capitalize}").new(
          #         Settings.infra.services[service][config.provider], config
          #       )
          #   end
          # end
        end
      end

      initializer 'ros_core.initialize_platform_metrics' do |app|
        app.config.middleware.insert_after(ActionDispatch::RequestId, Ros::DtraceMiddleware)
        if Settings.metrics.enabled
          require 'prometheus_exporter'
          # binding.pry
          require_relative '../prometheus_exporter/web_collector'
          require_relative '../prometheus_exporter/middleware'
          app.config.middleware.insert 0, Ros::PrometheusExporter::Middleware
          if Settings.metrics.process_stats_enabled
            # Reports basic process stats like RSS and GC info
            require 'prometheus_exporter/instrumentation'
            ::PrometheusExporter::Instrumentation::Process.start(type: 'master', frequency: Settings.metrics.frequency)
          end
          # Export Sidekiq metrics
          # See: https://github.com/discourse/prometheus_exporter#sidekiq-metrics
          if Sidekiq.server?
            Sidekiq.configure_server do |config|
              # Including Sidekiq metrics:
              config.server_middleware do |chain|
                require 'prometheus_exporter/instrumentation'
                chain.add ::PrometheusExporter::Instrumentation::Sidekiq
              end
              config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
              # monitor Sidekiq process info:
              ::PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
              # Sometimes Sidekiq shuts down before it can send metrics generated right before shutdown to collector
              # If you care about the sidekiq_restarted_jobs_total metric it is a good idea to explicitly stop the client:
              at_exit do
                ::PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
              end
            end
          end
          # Rails.logger = Sidekiq::Logging.logger
          # ActiveRecord::Base.logger = Sidekiq::Logging.logger
        end
      end

      initializer 'ros_core.initialize_request_logging' do |_app|
        if Settings.request_logging.enabled
          if Settings.request_logging.provider.eql? 'fluentd'
            require 'rack/fluentd_logger'
            require_relative '../request_logger/fluentd'
            Rack::FluentdLogger.configure(
              name: 'test-name', # Settings.service.name,
              host: Settings.request_logging.config.host,
              port: Settings.request_logging.config.port,
              # don't want to parse body to json, also underline MIME check code is not working
              json_parser: ->(d) { d },
              preprocessor: Ros::RequestLogger::Fluentd.preprocessor
            )
            Rails.application.config.middleware.insert 0, Rack::FluentdLogger
          end
        end
      end

      initializer 'ros_core.set_platform_hosts' do |app|
        app.config.hosts = app.config.hosts | Settings.hosts.split(',') if Settings.hosts
      end

      initializer 'ros_core.configure_apartment' do |_app|
        Apartment.configure do |config|
          if Settings.dig(:service, :name) # then we are in a service
            # Provide list of schemas to be migrated when rails db:migrate is invoked
            # SEE: https://github.com/influitive/apartment#managing-migrations
            config.tenant_names = proc { Tenant.pluck(:schema_name) }

            # List of models that are NOT multi-tenanted
            # See: https://github.com/influitive/apartment#excluding-models
            config.excluded_models = Ros.excluded_models
          end
        end
      end

      initializer 'ros_core.configure_jsonapi' do |_app|
        JSONAPI.configure do |config|
          # http://jsonapi-resources.com/v0.9/guide/resource_caching.html
          config.resource_cache = Rails.cache
          #:underscored_key, :camelized_key, :dasherized_key, or custom
          config.json_key_format = :underscored_key
          #:underscored_route, :camelized_route, :dasherized_route, or custom
          config.route_format = :underscored_route

          config.default_paginator = :paged
          config.default_page_size = 10
          config.maximum_page_size = 20
          config.top_level_meta_include_record_count = true
          config.top_level_meta_record_count_key = :record_count
          config.top_level_meta_include_page_count = true
          config.top_level_meta_page_count_key = :page_count
        end
        Mime::Type.register 'application/json-patch+json', :json_patch
      end

      initializer 'ros_core.configure_jsonapi_authorization' do |_app|
        JSONAPI.configure do |config|
          config.default_processor_klass = JSONAPI::Authorization::AuthorizingProcessor
          config.exception_class_whitelist = [Pundit::NotAuthorizedError]
        end

        JSONAPI::Authorization.configure do |config|
          config.authorizer = Ros::JsonapiAuthorization::Authorizer
        end
      end

      initializer 'ros.core.configure_platform_services_connections' do |_app|
        connection_type = Settings.dig(:connection, :type)
        client_config = Settings.dig(:connection, connection_type).to_h
        Ros::Platform::Client.configure(client_config.merge(connection_type: connection_type))
      end

      initializer 'ros_core.load_middleware' do |app|
        Warden::Strategies.add(:api_token, Ros::ApiTokenStrategy)
        app.config.middleware.use Warden::Manager do |manager|
          manager.default_strategies :api_token
          manager.failure_app = Ros::FailureApp
        end
        app.config.middleware.use Ros::TenantMiddleware
      end

      # Configure any error reporting services if their credential has been set
      # For now, only sentry.io is supported
      initializer 'ros_core.configure_error_reporting' do |_app|
        # export PLATFORM__CREDENTIALS__SENTRY_DSN=url
        if Settings.dig(:credentials, :sentry_dsn)
          require 'sentry-raven'
          Raven.configure do |config|
            config.dsn = Settings.credentials.sentry_dsn
          end
        end
      end

      initializer 'ros_core.configure_cors' do |app|
        if Settings.dig(:cors)
          require 'rack/cors'
          app.config.middleware.insert_before 0, Rack::Cors do
            allow do
              origins Settings.cors.origins
              resource Settings.cors.resource, headers: :any,
                                               methods: %i[get post delete put patch options head]
            end
          end
        end
      end

      initializer 'ros_core.configure_migrations' do |app|
        if Settings.dig(:service, :name) # then we are in a service
          config.paths['db/migrate'].expanded.each do |expanded_path|
            app.config.paths['db/migrate'] << expanded_path
            ActiveRecord::Migrator.migrations_paths << expanded_path
          end
        end
      end

      initializer 'ros_core.set_factory_paths', after: 'factory_bot.set_factory_paths' do
        if defined?(FactoryBot) && !Rails.env.production?
          FactoryBot.definition_file_paths.prepend(Ros.spec_root.join('factories'))
        end
      end

      config.after_initialize do
        require_relative 'console' unless Rails.const_defined?('Server')
        if Settings.event_logging.enabled
          if Settings.event_logging.provider.eql? 'fluentd'
            require_relative '../cloudevents/fluentd_avro_logger'
            Rails.configuration.x.event_logger = Ros::CloudEvents::FluentdAvroLogger.new(Settings.service.name,
              Settings.event_logging.config)
          end
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
