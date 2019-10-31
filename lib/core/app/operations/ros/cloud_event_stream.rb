# frozen_string_literal: true

module Ros
  class CloudEventStream < Ros::ActivityBase
    step :log_event
    # fail :log_error

    def log_event(_ctx, type:, message_id:, data:, **)
      puts ">>> type: #{type}"
      puts ">>> message_id: #{type}"
      puts ">>> data: #{type}"
      res = Rails.configuration.x.event_logger.log_event(type, message_id, data)
      puts "<<< #{res}"
      puts "<<< #{res.to_json}"
      puts "<<< #{res.inspect}"
      true
    end

    # def log_error(_ctx, errors:, **)
    #   errors.add(:logger, "Failed to log event")
    # end
  end
end
