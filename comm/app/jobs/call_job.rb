# frozen_string_literal: true

# TODO: Handle the tenant switch in Ros::ApplicationJob
class CallJob < Comm::ApplicationJob
  queue_as :default

  def perform(call:, tenant:)
    tenant.switch do
      # 'http://demo.twilio.com/docs/voice.xml')
      tenant.twilio_client.calls.create(from: call.from, to: call.to, url: call.url)
    end
  end
end
