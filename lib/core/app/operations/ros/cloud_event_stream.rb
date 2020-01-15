# frozen_string_literal: true

module Ros
  class CloudEventStream < Ros::ActivityBase
    step :log_event
    failed :log_error

    def log_event(ctx, type:, message_id:, data:, **)
      ctx[:res] = Rails.configuration.x.event_logger.log_event(type, message_id, data) # => Faraday::Response
      ctx[:res].success?
    rescue Faraday::Error => e
      ctx[:res] = OpenStruct.new(reason_phrase: e.message)
      false
    end

    def log_error(_ctx, res:, errors:, **)
      errors.add(:logger, res.reason_phrase)
    end
  end
end
