# frozen_string_literal: true

class MessageSend < Ros::ActivityBase
  step :retrieve_message
  failed :message_not_found
  step :send_message
  step :update_message_provider

  def retrieve_message(ctx, id:, **)
    ctx[:message] = Message.find(id)
  rescue ActiveRecord::RecordNotFound
    false
  end

  def message_not_found(_ctx, errors:, id:, **)
    errors.add(:message, "with #{id} not found")
  end

  def send_message(ctx, **)
    ctx[:msg_id] = ctx[:message].provider.send(ctx[:message].channel, ctx[:message].from, ctx[:message].to, ctx[:message].body)
  end

  def update_message_provider(ctx, **)
    ctx[:message].provider_msg_id = ctx[:msg_id]
    ctx[:message].save
  end
end
