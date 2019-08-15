# frozen_string_literal: true
require 'pry'

module Ros
  module Cognito
    class Engine < ::Rails::Engine
      config.generators.api_only = true
      config.generators do |g|
        g.test_framework :rspec, fixture: true
        g.fixture_replacement :factory_bot, dir: 'spec/factories'
      end

      # Adds this gem's db/migrations path to the enclosing application's migraations_path array
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

      initializer :autoload_services, after: :load_config_initializers do |app|
        Dir[Rails.root.join('../../services/**/*.rb')].each { |file| require file }
      end
    end
  end
end
