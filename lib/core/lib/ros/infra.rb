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
      # ENV.select{|e| e.start_with? 'AWS_'}.map{|e| e.delete_prefix('AWS_').downcase}

      def initialize(infra_config)
        @resources = ActiveSupport::OrderedOptions.new
        %i(mq storage).each do |service_type|
          next unless (service_resources = infra_config.dig(:resources, service_type))

          next unless (client_config = infra_config.dig(:clients, service_type))

          @resources[service_type] = ActiveSupport::OrderedOptions.new
          res_mod = "ros/infra/#{service_type}".classify.safe_constantize
          next unless (resource = service_resources.dig(res_mod.resource_type))

          mod = "ros/infra/#{infra_config.provider}/#{service_type}"
          require mod
          next unless (klass = mod.classify.safe_constantize)

          resource.each_pair do |name, config|
            @resources[service_type][name] = klass.new(config, client_config.to_hash)
          end
        end
      end
    end
  end
end
