# frozen_string_literal: true

module Ros
  class CloudEventStream < Ros::ActivityBase
    step :log_event

    def log_event(ctx, params:, **)
      Rails.configuration.x.event_logger.log_event(type, message_id, data)
    end
  end
end
