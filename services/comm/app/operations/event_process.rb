# frozen_string_literal: true

# NOTE: Might be more worthy to implement this using TRB operation instead
class EventProcess < Trailblazer::Activity::FastTrack
  # rubocop:disable Style/SignalException
  step :find_event
  fail :event_not_found, fail_fast: true
  step :setup_context
  step :process_event
  # rubocop:enable Style/SignalException

  def find_event(ctx, params)
    ctx[:model] = ::Event.find_by(params)
  end

  def event_not_found(_ctx, params)
    ctx[:errors] << "{EventProcess} Can't find event (#{params}) for tenant"
  end

  def setup_context(ctx, _params)
    ctx[:template] = ctx[:model].template
    ctx[:campaign] = ctx[:model].campaign
  end

  def process_event(ctx, params)
    event = ctx[:model]
    event.process!
    event.users.each do |user|
      content = ctx[:template].render(user, ctx[:campaign])
      event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
    end
    event.publish!
  end
end
