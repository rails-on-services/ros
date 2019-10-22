# frozen_string_literal: true

class MessageCreate < ActivityBase
  # rubocop:disable Style/SignalException
  step :setup_message
  fail :invalid_message
  step :save_sms
  setp :send_to_provider
  # rubocop:enable Style/SignalException

  def setup_message(ctx, params:, **)
    # Params shuld have something like:
    # (provider: event.provider, channel: event.channel, to: user.phone_number, body: content, from: ....)
    ctx[:model] = Message.new(params)
    ctx[:model].valid?
  end

  def invalid_message(ctx, model:, **)
    ctx[:errors] = model.errors
  end

  def save_sms(_ctx, model:, **)
    model.save
  end

  def send_to_provider(_ctx, model:, **)
    model.provider.send(model.channel, model.to, model.from)
  end
end
