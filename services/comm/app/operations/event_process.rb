# frozen_string_literal: true

# NOTE: Might be more worthy to implement this using TRB operation instead
class EventProcess < Trailblazer::Activity::FastTrack
  # rubocop:disable Style/SignalException
  step :find_event, input: [:params], output: %i[event template campaign]
  fail :event_not_found, fail_fast: true
  step :process_event
  # rubocop:enable Style/SignalException

  def find_event(ctx, params)
    event = ::Event.find_by(params)
    return false unless event

    ctx[:event] = event
    ctx[:template] = event.template
    ctx[:campaign] = event.campaign
  end

  def event_not_found(_ctx)
    ctx[:errors] << "{EventProcess} Can't find event (#{params}) for tenant"
  end

  def process_event(_ctx, event:, template:, campaign:)
    event.process!
    event.users.each do |user|
      content = template.render(user, campaign)
      event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
    end
    event.publish!
  end
end
