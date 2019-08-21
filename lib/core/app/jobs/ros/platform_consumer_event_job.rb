# frozen_string_literal: true

module Ros
  class InvalidTenantError < StandardError
    # Rails.logger.debug("Schema name #{schema_name}")
  end
  # PlatformProducerEventJob#perform enqueus this job on the listening service's queue
  # When a message is received, parse the payload, get the URN and switch to the tenant
  # Then call a method on PlatformEventProcessor that is named <producer_service>+<resource_type>
  # TODO: Implement PlatformEventProcessor class in each service
  class PlatformConsumerEventJob < Ros::ApplicationJob
    queue_as "#{Settings.service.name}_platform_consumer_events"

    def perform(object)
        puts("\n+++++++++ Start\n")
          binding.remote_pry
      puts object
        puts("+++++++++ End\n\n")
      payload = JSON.parse(object)
      event = payload['event']
      data = payload['data']
      urn = Ros::Urn.from_urn(data['urn'])
      if urn.is_platform_urn?
        Rails.logger.debug("\n*******\n")
        method = 'tenant'
        PlatformEventProcessor.send(method, urn: urn, event: event, data: data)
        return
      end
      schema_name = Tenant.account_id_to_schema(urn.account_id)
      tenant = Tenant.find_by(schema_name: schema_name)
      raise InvalidTenantError unless tenant
      tenant.switch do
        method = "#{urn.service_name}_#{urn.resource_type}"
        PlatformEventProcessor.send(method, urn: urn, event: event, data: data)
      end
    end
  end
end
