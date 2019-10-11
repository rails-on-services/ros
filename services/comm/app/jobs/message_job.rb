# frozen_string_literal: true

# TODO: Handle the tenant switch in Ros::ApplicationJob
class MessageJob < Comm::ApplicationJob
  queue_as :comm_default

  # MessagesController receives a POST request to create a message (sms) with details of from, to and body
  # After the record is created, a Job is created to send to the destination
  # This means that the correct tenant must be selected by apartment
  def perform(message, tenant_id)
    tenant = Tenant.find(tenant_id)
    tenant.switch do
      message.provider.send(message.channel, message)
    end
  end
end
