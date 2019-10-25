# frozen_string_literal: true

class MessageCreate < Ros::ActivityBase
  # rubocop:disable Style/SignalException
  # rubocop:disable Lint/UnreachableCode
  step :valid_send_at
  # NOTE: Fail fast is not available in a Railway activity
  fail :invalid_send_at, Output(:failure) => End(:failure), Output(:success) => End(:failure)
  step :setup_message
  fail :invalid_message
  step :save_sms
  step :send_to_provider
  # rubocop:enable Lint/UnreachableCode
  # rubocop:enable Style/SignalException

  # NOTE: Ensures that if send_at was sent then it is a valid date/datetime
  # If send_at is sent and valid, we store it in context, else we jump
  # to the error track.
  # If send_at is not sent we will not delay the sms sending and instead send
  # it immediately
  def valid_send_at(ctx, **)
    return true if ctx[:send_at].blank?

    begin
      parsed_send_at = Time.zone.parse(ctx[:send_at])
      return false if parsed_send_at.nil?

      ctx[:send_at] = parsed_send_at
    rescue ArgumentError
      return false
    end

    !ctx[:send_at].nil?
  end

  def invalid_send_at(ctx, **)
    ctx[:errors].add(:send_at, "is not a valid date format (send_at: #{ctx[:send_at]})")
  end

  def setup_message(ctx, params:, **)
    ctx[:model] = Message.new(params)
    ctx[:model].valid?
  end

  def invalid_message(ctx, model:, **)
    ctx[:errors] = model.errors
  end

  def save_sms(_ctx, model:, **)
    model.save
  end

  def send_to_provider(ctx, model:, **)
    if ctx[:send_at].present?
      MessageJob.set(wait_until: ctx[:send_at]).perform_later(id: model.id)
    else
      MessageJob.perform_now(id: model.id)
    end
  end
end
