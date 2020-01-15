# frozen_string_literal: true

class EventProcess < Ros::ActivityBase
  step :find_event
  failed :event_not_found
  step :create_messages_for_pool

  def find_event(ctx, id:, **)
    event = ::Event.find(id)
    # TODO: What if campaign is not set? This returns nil and fails
    ctx[:event] = event
    ctx[:template] = event.template
    ctx[:campaign] = event.campaign
  rescue ActiveRecord::RecordNotFound
    false
  end

  def event_not_found(_ctx, id:, errors:, **)
    errors.add(:event, "not found for tenant (id: #{id})")
  end

  def create_messages_for_pool(_ctx, event:, template:, campaign:, **)
    event.process!
    event.users.each do |user|
      content = template.render(user: user, campaign: campaign)
      MessageCreate.call(params: { to: user.phone_number,
                                   provider: event.provider,
                                   channel: event.channel,
                                   body: content,
                                   owner: event })
    end
    event.publish!
  end
end
