# frozen_string_literal: true

require_relative 'console'

module Ros
  module Iam
    class Engine < ::Rails::Engine
      config.generators.api_only = true
      config.generators do |g|
        g.test_framework :rspec, fixture: true
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
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

      initializer :platform_settings do |app|
        settings_path = root.join('config/settings')
        Settings.prepend_source!("#{settings_path}.yml")
        Settings.reload!
      end if File.exists? root.join('config/settings.yml')

      initializer :console_methods do |app|
        Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
        Ros.config.model_paths += config.paths['app/models'].expanded
      end if Rails.env.development?

      initializer :devise_jwt do |app|
        # Warden::JWTAuth.configure do |config|
        #   # TODO: Get configuration from ENVs/file
        #   config.secret = Rails.application.credentials.dig(:platform, :jwt_secret) || ENV['PLATFORM_JWT_SECRET'] || 'abcd1234'
        #   config.mappings = { user: UserRepository }
        #   # config.revocation_strategies = { user: RevocationStrategy }
        # end
        # app.config.middleware.use Warden::JWTAuth::Middleware
      end

      initializer :service_values do |app|
        name = self.class.parent.name.demodulize.underscore
        Settings.prepend_source!({ service: { name: name, policy_name: name.capitalize } })
      end
    end
  end
end
