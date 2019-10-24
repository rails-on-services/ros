# frozen_string_literal: true

class MessageJob < Comm::ApplicationJob
  # MessagesController receives a POST request to create a message (sms) with details of from, to and body
  # After the record is created, a Job is created to send to the destination
  # This means that the correct tenant must be selected by apartment
  def perform(params)
    message = Message.find_by(params)
    message.provider.send(message.channel, message.to, message.from)
  end
end
