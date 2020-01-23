# frozen_string_literal: true

# This file is auto-generated during the install process.
# If by any chance you've wanted a setup for Rails app, either run the `karafka:install`
# command again or refer to the install templates available in the source codes

ENV['RAILS_ENV'] ||= 'development'
ENV['KARAFKA_ENV'] ||= ENV['RAILS_ENV']
require ::File.expand_path('../spec/dummy/config/environment', __FILE__)
Rails.application.eager_load!

# This lines will make Karafka print to stdout like puma or unicorn
if Rails.env.development?
  Rails.logger.extend(
    ActiveSupport::Logger.broadcast(
      ActiveSupport::Logger.new($stdout)
    )
  )
end

class KarafkaApp < Karafka::App
  setup do |config|
    kafka_enabled = Settings.dig(:infra, :services, :kafka, :enabled)
    next unless kafka_enabled

    config.kafka.seed_brokers = Settings.infra.services.kafka.bootstrap_servers.split(',').map do |broker|
      broker = "kafka://#{broker}" unless broker.starts_with? "kafka://"
    end
    if Settings.infra.services.kafka.security_protocol == 'SASL_SSL' && Settings.infra.services.kafka.sasl_mechanism == 'PLAIN'
      config.kafka.sasl_plain_username = Settings.infra.services.kafka.username
      config.kafka.sasl_plain_password = Settings.infra.services.kafka.password
    end
    config.client_id = 'comm-service'
    config.logger = Rails.logger
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  Karafka.monitor.subscribe(WaterDrop::Instrumentation::StdoutListener.new)
  Karafka.monitor.subscribe(Karafka::Instrumentation::StdoutListener.new)
  Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)

  # Uncomment that in order to achieve code reload in development mode
  # Be aware, that this might have some side-effects. Please refer to the wiki
  # for more details on benefits and downsides of the code reload in the
  # development mode
  #
  # Karafka.monitor.subscribe(
  #   Karafka::CodeReloader.new(
  #     APP_LOADER
  #   )
  # )

  consumer_groups.draw do
    topic :tenant_created do
      consumer Ros::TenantCreateConsumer
    end

    topic :tenant_updated do
      consumer Ros::TenantUpdateConsumer
    end
    # topic :example do
    #   consumer ExampleConsumer
    # end

    # consumer_group :bigger_group do
    #   topic :test do
    #     consumer TestConsumer
    #   end
    #
    #   topic :test2 do
    #     consumer Test2Consumer
    #   end
    # end
  end
end

Karafka.monitor.subscribe('app.initialized') do
  # Put here all the things you want to do after the Karafka framework
  # initialization
end

KarafkaApp.boot!
