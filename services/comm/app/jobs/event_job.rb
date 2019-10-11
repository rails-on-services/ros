# frozen_string_literal: true

# TODO: Handle the tenant switch in Ros::ApplicationJob
class EventJob < Comm::ApplicationJob
  queue_as :default

  # MessagesController receives a POST request to create a message (sms) with details of from, to and body
  # After the record is created, a Job is created to send to the destination
  # This means that the correct tenant must be selected by apartment
  def perform(event, tenant_id)
    @tenant_id = tenant_id
    @event = event
    tenant.switch do
      event.process!
      event.users.each do |user|
        content = build_message_content
        event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
      end
      event.publish!
    end
  end

  private

  def build_message_content(user)
    template.properties.user = user
    template.properties.endpoint = campaign.base_url || tenant.properties.campaign_base_url
    template.render
  rescue NoMethodError => e
    # TODO: Some kind of 'cloudwatch' event reporting situation
    # so that events are logged that the tenant user can view
    Rails.logger.warn "error rendering template #{e.message}"
    nil
  end

  def tenant
    @tenant ||= Tenant.find(@tenant_id)
  end

  def template
    @template ||= @event.template
  end

  def campaign
    @campaign ||= @event.campaign
  end
end
