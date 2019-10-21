# frozen_string_literal: true

module Ros
  # ApplicationRecordConcern after_commit enques this job
  # If any event listeners have been configured for this object+event combination then
  # enque a PlatformConsumerEventJob on the listening service's platform_consumer_events queue
  class StreamCloudEventJob < Ros::ApplicationJob
    def perform(type, message_id, data)
      Rails.configuration.x.event_logger.log_event(type, message_id, data)
    end
  end
end
