# frozen_string_literal: true

class MessageSend < Ros::ActivityBase
  step :retrieve_message
  failed :message_not_found, Output(:success) => End(:failure)
  step :check_if_phone_number_is_opted_in
  failed :phone_number_opted_out, Output(:success) => End(:failure)
  step :send_message
  step :update_message_provider_id

  def retrieve_message(ctx, id:, **)
    ctx[:message] = Message.find_by(id: id)
  end

  def message_not_found(_ctx, errors:, id:, **)
    errors.add(:message, "with #{id} not found")
  end

  def check_if_phone_number_is_opted_in(_ctx, message:, **)
    !message.provider.phone_number_opted_out?(message.to)
  end

  def phone_number_opted_out(_ctx, errors:, message:, **)
    errors.add(:phone_number, "#{message.to} is already opted out")
  end

  def send_message(ctx, message:, **)
    ctx[:msg_id] = message.provider.send(message.channel, message.from, message.to, message.body)
  end

  def update_message_provider_id(ctx, message:, **)
    message.provider_msg_id = ctx[:msg_id]
    message.save
  end
end
