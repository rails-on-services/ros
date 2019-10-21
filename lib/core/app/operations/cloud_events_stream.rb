# frozen_string_literal: true

class CloudEventsStream
  def call(type, message_id, data)
    Rails.configuration.x.event_logger.log_event(type, message_id, data)
  end
end
