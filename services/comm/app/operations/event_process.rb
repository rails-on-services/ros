# frozen_string_literal: true

class EventProcess < Ros::ActivityBase
  # rubocop:disable Style/SignalException
  # rubocop:disable Lint/UnreachableCode
  step :find_event
  fail :event_not_found
  step :create_messages_for_pool
  # rubocop:enable Lint/UnreachableCode
  # rubocop:enable Style/SignalException

  def find_event(ctx, params:, **)
    event = ::Event.find_by(params)
    return false unless event

    # TODO: What if campaign is not set? This returns nil and fails
    ctx[:event] = event
    ctx[:template] = event.template
    ctx[:campaign] = event.campaign
  end

  def event_not_found(_ctx, params:, errors:, **)
    errors.add(:event, "not found for tenant (params: #{params})")
  end

  def create_messages_for_pool(_ctx, event:, template:, campaign:, **)
    event.process!
    event.users.each do |user|
      content = template.render(user, campaign)

      MessageCreate.call(params: { to: user.phone_number,
                                   provider: event.provider,
                                   channel: event.channel,
                                   body: content,
                                   owner: event })
    end
    event.publish!
  end
end
