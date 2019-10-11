# frozen_string_literal: true

# TODO: Handle the tenant switch in Ros::ApplicationJob
class EventJob < Comm::ApplicationJob
  queue_as :comm_default

  # MessagesController receives a POST request to create a message (sms) with details of from, to and body
  # After the record is created, a Job is created to send to the destination
  # This means that the correct tenant must be selected by apartment
  def perform(event_id, tenant)
    Apartment::Tenant.switch!(tenant)
    event = Event.find(event_id)
    if event
      process_event(event)
    else
      Rails.logger.info "{EventJob} Can't find event (#{event_id}) for tenant (#{tenant.schema_name})"
    end
  end

  private

  def process_event(event)
    event.process!
    event.users.each do |user|
      content = template.render(user, campaign)
      event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
    end
    event.publish!
  end

  def template
    @template ||= @event.template
  end

  def campaign
    @campaign ||= @event.campaign
  end
end
