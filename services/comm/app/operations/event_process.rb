# frozen_string_literal: true

class EventProcess < ActivityBase
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

      # res = MessageCreate.call(params: { user: user, content: content })
      event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
    end
    event.publish!
  end
end
