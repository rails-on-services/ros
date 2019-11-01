# frozen_string_literal: true

module Ros
  class CloudEventStream < Ros::ActivityBase
    # rubocop:disable Style/SignalException
    step :log_event
    fail :log_error
    # rubocop:enable Style/SignalException

    # rubocop:disable Lint/UnreachableCode
    def log_event(ctx, type:, message_id:, data:, **)
      # binding.pry
      ctx[:res] = Rails.configuration.x.event_logger.log_event(type, message_id, data) # => Faraday::Response
      ctx[:res].success?
    rescue Faraday::Error => e
      ctx[:res] = OpenStruct.new(reason_phrase: e.message)
      false
    end
    # rubocop:enable Lint/UnreachableCode

    def log_error(_ctx, res:, errors:, **)
      errors.add(:logger, res.reason_phrase)
    end
  end
end
