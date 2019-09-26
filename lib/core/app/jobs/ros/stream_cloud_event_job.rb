# frozen_string_literal: true

module Ros
  # ApplicationRecordConcern after_commit enques this job
  # If any event listeners have been configured for this object+event combination then
  # enque a PlatformConsumerEventJob on the listening service's platform_consumer_events queue
  class StreamCloudEventJob < Ros::ApplicationJob
    queue_as "#{Settings.service.name}_stream_cloud_event"

    def perform(object)
      type = "#{Settings.service.name}.#{object.class.name.downcase}"
      message_id = object.id # SecureRandom.uuid
      data = object.as_json
      # data = { id: object.id, username: object.username, time_zone: object.time_zone }.to_json
      Rails.configuration.x.event_logger.log_event(type, message_id, data)
    end
  end
end
