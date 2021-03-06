# frozen_string_literal: true

module Providers
  class Twilio < Provider
    alias_attribute :account_sid, :credential_1
    alias_attribute :auth_token, :credential_2

    def client
      @client ||= ::Twilio::REST::Client.new(x_account_sid, x_auth_token) if x_account_sid && x_auth_token
    end

    def x_account_sid
      account_sid || (current_tenant.platform_twilio_enabled ? ENV['TWILIO_ACCOUNT_SID'] : nil)
    end

    def x_auth_token
      auth_token || (current_tenant.platform_twilio_enabled ? ENV['TWILIO_AUTH_TOKEN'] : nil)
    end

    def sms(from, to, body)
      sender = from || provider_from
      # Rails.logger.warn('No Twilio client configured for tenant.account_id') and return unless client
      # message.update(from: from)
      # binding.pry
      # TODO: toggle sending on and off
      client.messages.create(from: sender, to: to, body: body)
      Rails.logger.debug message
    end

    def call(_message)
      # to = whatup.From.gsub('whatsapp:', '')
      client.calls.create(from: from, to: to, url: 'http://demo.twilio.com/docs/voice.xml')
    end
  end
end
