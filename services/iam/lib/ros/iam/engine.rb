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

      initializer 'service.set_platform_config', before: 'ros_core.load_platform_config' do |_app|
        settings_path = root.join('config/settings.yml')
        Settings.prepend_source!(settings_path) if File.exists? settings_path
        name = self.class.parent.name.demodulize.underscore
        Settings.prepend_source!({ service: { name: name, policy_name: name.capitalize } })
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

      initializer 'service.configure_console_methods' do |_app|
        if Rails.env.development? and not Rails.const_defined?('Server')
          Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
        end
      end

      initializer 'service.configure_devise_jwt' do |app|
        # Warden::JWTAuth.configure do |config|
        #   # TODO: Get configuration from ENVs/file
        #   config.secret = Rails.application.credentials.dig(:platform, :jwt_secret) || ENV['PLATFORM_JWT_SECRET'] || 'abcd1234'
        #   config.mappings = { user: UserRepository }
        #   # config.revocation_strategies = { user: RevocationStrategy }
        # end
        # app.config.middleware.use Warden::JWTAuth::Middleware
      end
    end
  end
end
