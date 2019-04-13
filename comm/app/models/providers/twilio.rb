# frozen_string_literal: true

module Providers
  class Twilio < Provider
    def self.credentials_keys; %w(TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN) end

    def self.services; %w(sms) end

    def client
      @client ||= ::Twilio::REST::Client.new(account_sid, auth_token) if account_sid and auth_token
    end

    def account_sid
      credentials_hash['TWILIO_ACCOUNT_SID'] || current_tenant.platform_twilio_enabled ? ENV['TWILIO_ACCOUNT_SID'] : nil
    end

    def auth_token
      credentials_hash['TWILIO_AUTH_TOKEN'] || current_tenant.platform_twilio_enabled ? ENV['TWILIO_AUTH_TOKEN'] : nil
    end

    # TODO: Get from provider
    def from; '+12565308753' end

    def sms(message)
      message.update(from: from)
      # binding.pry
      # TODO: toggle sending on and off
      res = client.messages.create(from: from, to: message.to, body: message.body)
      # p res
      p message
    # rescue
      # Rails.logger.warn('No Twilio client configured for tenant.account_id') and return if tenant.twilio_client.nil?
    end

    # Dotenv.load('../../app.env')
    # Get your Account Sid and Auth Token from twilio.com/console
    # set up a client to talk to the Twilio REST API
    # @twilio_client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    # from = '+12565308753'
    # to = whatup.From.gsub('whatsapp:', '')

    # @twilio_client.calls.create(from: from, to: to, url: 'http://demo.twilio.com/docs/voice.xml')
    #Tenant.find_by(schema_name: tenant.schema_name)
  end
end
