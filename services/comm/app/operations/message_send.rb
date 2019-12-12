# frozen_string_literal: true

class MessageSend < Ros::ActivityBase
  step :retrieve_message
  step :send_message
  step :update_message_provider

  def retrieve_message(ctx, id:, **)
    ctx[:message] = Message.find(id)
  end

  def send_message(ctx, **)
    ctx[:msg_id] = ctx[:message].provider.send(ctx[:message].channel, ctx[:message].to, ctx[:message].from)
  end

  def update_message_provider(ctx, **)
    ctx[:message].provider_msg_id = ctx[:msg_id]
    ctx[:message].save
  end
end
