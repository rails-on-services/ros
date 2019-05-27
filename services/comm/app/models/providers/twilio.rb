# frozen_string_literal: true

module Providers
  class Twilio < Provider
    alias_attribute :account_sid, :credential_1
    alias_attribute :auth_token, :credential_2

    def self.services; %w(sms call) end

    def client
      @client ||= ::Twilio::REST::Client.new(x_account_sid, x_auth_token) if x_account_sid and x_auth_token
    end

    def x_account_sid
      account_sid || current_tenant.platform_twilio_enabled ? ENV['TWILIO_ACCOUNT_SID'] : nil
    end

    def x_auth_token
      auth_token || current_tenant.platform_twilio_enabled ? ENV['TWILIO_AUTH_TOKEN'] : nil
    end

    # TODO: Get from provider
    def from; '+12565308753' end

    def sms(message)
      # Rails.logger.warn('No Twilio client configured for tenant.account_id') and return unless client
      message.update(from: from)
      # binding.pry
      # TODO: toggle sending on and off
      res = client.messages.create(from: from, to: message.to, body: message.body)
      # p res
      p message
    end

    def call(message)
      # to = whatup.From.gsub('whatsapp:', '')
      client.calls.create(from: from, to: to, url: 'http://demo.twilio.com/docs/voice.xml')
    end
  end
end
