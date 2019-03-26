# frozen_string_literal: true

require_relative '../../migrations'
require_relative 'console'

module Ros
  module Core
    class Engine < ::Rails::Engine
      config.generators.api_only = true
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

      initializer :platform_hosts do |app|
        # if Settings.config.hosts.is_a? Array
        #   app.config.hosts + Setting.config.hosts
        # else
          # app.config.hosts << Settings.config.hosts'whistler-api.perxtech.org'
          app.config.hosts << 'whistler-api.perxtech.org'
      end # if Settings.dig(:config, :hosts)

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
        connection_type = Settings.dig(:services, :connection, :type)
        client_config = Settings.dig(:services, :connection, connection_type).to_h
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

      initializer :documentation do |app|
        require 'open_api'
        OpenApi::Config.tap do |config|
          config.instance_eval do
            open_api 'ros-api', base_doc_classes: [ApplicationDoc]
            info version: '0.0.1', title: 'APIs', description: 'API documentation.'
            server 'http://localhost:3000', desc: 'Main (production) server'
            bearer_auth :Authorization
          end
          config.file_output_path = '.docs'
        end
      end

      initializer :rack_cors do |app|
        # First, get settings.yml working from spec/dummy and application so app controls CORS
        # if Settings.dig(:cors)
        require 'rack/cors'
        app.config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins '*'
            resource '*', headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
          end
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
