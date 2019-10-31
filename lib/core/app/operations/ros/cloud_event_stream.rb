# frozen_string_literal: true

module Ros
  class CloudEventStream < Ros::ActivityBase
    step :log_event
    # fail :log_error

    def log_event(_ctx, type:, message_id:, data:, **)
      Rails.configuration.x.event_logger.log_event(type, message_id, data) # => Faraday::Response
      true
    end

    # def log_error(_ctx, errors:, **)
    #   errors.add(:logger, "Failed to log event")
    # end
  end
end
