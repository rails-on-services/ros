# frozen_string_literal: true

class MessageSendJob < Comm::ApplicationJob
  def perform(params)
    message = Message.find_by(params)
    msid = message.provider.send(message.channel, message.to, message.from)
    message.provider_msg_id = msid
    message.save
  end
end
