# frozen_string_literal: true

require 'ros/infra/storage'
require 'ros/infra/mq'

module Ros
  class << self
    attr_accessor :infra
  end

  module Infra
    class << self
      attr_accessor :resources

      def initialize(resources_settings)
        @resources = ActiveSupport::OrderedOptions.new
        %i(mq storage).each do |service|
          resources = resources_settings.dig(service)
          next unless resources&.primary&.enabled
          @resources[service] = ActiveSupport::OrderedOptions.new
          resource_type = "Ros::Infra::#{service.to_s.classify}".constantize.resource_type
          next unless (resource = resources.dig(resource_type))
          resource.each_pair do |name, config|
            require "ros/infra/#{config.provider}/#{service}"
            klass = "Ros::Infra::#{config.provider.capitalize}::#{service.capitalize}".constantize
            @resources[service][name] = klass.new(config)
          end
        end
      end
    end
  end
end
