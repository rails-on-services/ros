# frozen_string_literal: true

require 'ros/core'

module Storage
  class Engine < ::Rails::Engine
    config.generators.api_only = true
    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end

    initializer :infra_services_storage do |_app|
      if Rails.configuration.x.infra.class.to_s.eql? 'ActiveSupport::OrderedOptions'
        Rails.configuration.x.infra = Rails::Application::Configuration::Custom.new
      end
      # binding.pry
      Settings.infra.services.each.collect.map { |p| p[1].provider }.uniq.each do |provider|
        if provider.eql? 'aws'
          require 'aws-sdk-sqs'
          Rails.configuration.x.infra.aws.sqs = Aws::SQS::Client.new(
            Settings.infra.providers.aws.credentials.to_h.merge(
              Settings.infra.providers.aws.services.mq.to_h
            )
          )
          require 'shoryuken'
          Shoryuken.configure_server { |config| config.sqs_client = Rails.configuration.x.infra.aws.sqs }
        elsif provider.eql? 'gcp'
        end
      end
    end

    # Adds this gem's db/migrations path to the enclosing application's migraations_path array
    # if the gem has been included in an application, i.e. it is not running in the dummy app
    # https://github.com/rails/rails/issues/22261
    initializer :append_migrations do |app|
      unless app.config.paths['db/migrate'].first.include? 'spec/dummy'
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
          ActiveRecord::Migrator.migrations_paths << expanded_path
        end
      end
    end

    initializer :console_methods do |_app|
      if Rails.env.development?
        Ros.config.factory_paths += Dir[Pathname.new(__FILE__).join('../../../../spec/factories')]
        Ros.config.model_paths += config.paths['app/models'].expanded
      end
    end

    initializer :service_values do |_app|
      name = 'storage' # self.class.parent.name.demodulize.underscore
      Settings.prepend_source!(service: { name: name, policy_name: name.capitalize })
      Settings.reload!
      # binding.pry
      # Settings.service.name = name
      # Settings.service.policy_name = name.capitalize
    end
  end
end
