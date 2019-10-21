# frozen_string_literal: true

module Ros
  # When a job is received in the service's queue then parse the event payload
  # Then switch to the tenant as specified by the event
  # and invoke the method on PlatformEventProcessor that is specified in the event
  # And a PlatformEventProcessorConcern in the core with the common methods
  class PlatformEventJob < Ros::ApplicationJob
    queue_as "#{Settings.service.name}_platform_consumer_events"

    def perform(serialized_event)
      event = Ros::PlatformEvent.new(serialized_event)
      # TODO: Implement PlatformEventProcessor class in each service
      event.tenant.switch { PlatformEventConsumer.new(event).send(event.method) }
    end
  end
end
