# frozen_string_literal: true

class CallJob < Comm::ApplicationJob
  def perform(call:)
    # 'http://demo.twilio.com/docs/voice.xml')
    @tenant.twilio_client.calls.create(from: call.from, to: call.to, url: call.url)
  end
end
