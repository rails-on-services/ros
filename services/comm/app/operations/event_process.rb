# frozen_string_literal: true

# NOTE: Might be more worthy to implement this using TRB operation instead
class EventProcess < ActivityBase
  # rubocop:disable Style/SignalException
  step :find_event
  fail :event_not_found
  step :create_messages_for_pool
  # rubocop:enable Style/SignalException

  def find_event(ctx, params:, **)
    event = ::Event.find_by(params)
    return false unless event

    ctx[:model] = event
    ctx[:template] = event.template
    ctx[:campaign] = event.campaign
  end

  def event_not_found(_ctx, params:, errors:, **)
    errors.add(:event, "not found for tenant (#{params})")
  end

  def create_messages_for_pool(_ctx, model:, template:, campaign:, **)
    event.process!
    event.users.each do |user|
      content = template.render(user, campaign)
      event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
    end
    event.publish!
  end
end
