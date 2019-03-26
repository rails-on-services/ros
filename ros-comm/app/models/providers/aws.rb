# frozen_string_literal: true

module Providers
  class Aws < Provider
    def self.credentials_keys; %w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY) end

    def self.services; %w(sms) end

    def client
      @client ||= Aws::SNS::Client.new()
    end

    def account_sid
      credentials_hash['AWS_ACCESS_KEY_ID'] || current_tenant.platform_twilio_enabled ? ENV['AWS_SECRET_ACCESS_KEY'] : nil
    end

    def auth_token
      credentials_hash['AWS_ACCESS_KEY_ID'] || current_tenant.platform_twilio_enabled ? ENV['AWS_SECRET_ACCESS_KEY'] : nil
    end

    # TODO: Get from provider
    def from; '+12565308753' end

    def sms(message)
      # TODO: toggle sending on and off
      # res = client.messages.create(from: from, to: message.to, body: message.body)
      # p res
      p message
    # rescue
      # Rails.logger.warn('No Twilio client configured for tenant.account_id') and return if tenant.twilio_client.nil?
    end
  end
end
