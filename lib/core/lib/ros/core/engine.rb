# frozen_string_literal: true

require_relative '../../migrations'
require_relative 'console'

module Ros
  module Core
    class Engine < ::Rails::Engine
      config.generators.api_only = true
      # TODO: Make this configurable from ros config/platform.yml
      config.active_job.queue_adapter = :sidekiq
      config.generators do |g|
        g.test_framework :rspec, fixture: true
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end

      # NOTE: ENV vars indicate hierarchy with two underscores '__'
      # export PLATFORM__CREDENTIALS__JWT_ENCRYPTION_KEY='test'
      initializer :platform_settings do |app|
        settings_path = root.join('config/settings')
        # NOTE: Sources are prepended in reverse order, meaning the first prepend is loaded last
        Settings.prepend_source!({ credentials: Rails.application.credentials.config })
        Settings.prepend_source!("#{settings_path}.yml")
        Settings.reload!
      end

      initializer :platform_metrics do |app|
        if Settings.metrics.enabled
          require 'prometheus_exporter'
          # binding.pry
          require_relative '../prometheus_exporter/web_collector'
          require_relative '../prometheus_exporter/middleware'
          Rails.application.config.middleware.insert 0, Ros::PrometheusExporter::Middleware
          if Settings.metrics.process_stats_enabled
            # Reports basic process stats like RSS and GC info
            require 'prometheus_exporter/instrumentation'
            PrometheusExporter::Instrumentation::Process.start(type: 'master', frequency: Settings.metrics.frequency)
          end
        end
      end

      initializer :request_logging do |app|
        if Settings.request_logging.enabled
          if Settings.request_logging.provider.eql? 'fluentd'
            require 'rack/fluentd_logger'
            require_relative '../request_logger/fluentd'
            Rack::FluentdLogger.configure(
              name: Settings.service.name,
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

      config.after_initialize do
        if Settings.system_logging.enabled
          if Settings.system_logging.provider.eql? 'fluentd'
            Rails.configuration.x.logger =
              Fluent::Logger::LevelFluentLogger.new(Settings.service.name, Settings.system_logging.config.to_h)
            Rails.configuration.x.logger.formatter = proc do |severity, datetime, progname, message|
              map = { level: severity }
              map[:message] = message if message
              map[:progname] = progname if progname
              map[:stage] = ENV['RAILS_ENV']
              map[:service_name] = Settings.service.name
              map
            end
            Rails.logger = Rails.configuration.x.logger
            ActiveRecord::Base.logger = Rails.configuration.x.logger
          end
        end
      end

      initializer :platform_hosts do |app|
        app.config.hosts = app.config.hosts | Settings.hosts.split(',') if Settings.hosts
      end

      initializer :apartment do |app|
        Apartment.configure do |config|
          # Provide list of schemas to be migrated when rails db:migrate is invoked
          # SEE: https://github.com/influitive/apartment#managing-migrations
          config.tenant_names = proc { Tenant.pluck(:schema_name) }

          # List of models that are NOT multi-tenanted
          # See: https://github.com/influitive/apartment#excluding-models
          config.excluded_models = Tenant.excluded_models
        end
      end

      initializer :jsonapi_configuration do |app|
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
        end
        Mime::Type.register 'application/json-patch+json', :json_patch
      end

      initializer :jsonapi_authorization do |app|
        JSONAPI.configure do |config|
          config.default_processor_klass = JSONAPI::Authorization::AuthorizingProcessor
          config.exception_class_whitelist = [Pundit::NotAuthorizedError]
        end
      end

      initializer :platform_services_connections do |app|
        connection_type = Settings.dig(:connection, :type)
        client_config = Settings.dig(:connection, connection_type).to_h
        Ros::Platform::Client.configure(client_config.merge(connection_type: connection_type))
      end

      initializer :load_middleware do |app|
        Warden::Strategies.add(:api_token, Ros::ApiTokenStrategy)
        app.config.middleware.use Warden::Manager do |manager|
          manager.default_strategies :api_token
          manager.failure_app = Ros::FailureApp
        end
        app.config.middleware.use Ros::TenantMiddleware
      end

      # Configure any error reporting services if their credential has been set
      # For now, only sentry.io is supported
      initializer :error_reporting_services do |app|
        # export PLATFORM__CREDENTIALS__SENTRY_DSN=url
        if Settings.dig(:credentials, :sentry_dsn)
          require 'sentry-raven'
          Raven.configure do |config|
            config.dsn = Settings.credentials.sentry_dsn
          end
        end
      end

      initializer :rack_cors do |app|
        if Settings.dig(:cors)
          require 'rack/cors'
          app.config.middleware.insert_before 0, Rack::Cors do
            allow do
              origins Settings.cors.origins
              resource Settings.cors.resource, headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
            end
          end
        end
      end

      initializer :core_append_migrations do |app|
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
          ActiveRecord::Migrator.migrations_paths << expanded_path
        end
      end

      # Add console methods from ./console.rb
      config.after_initialize do
        Ros::Console::Methods.init
        TOPLEVEL_BINDING.eval('self').extend Ros::Console::Methods
      end
    end
  end
end
