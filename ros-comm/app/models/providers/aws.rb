# frozen_string_literal: true

module Providers
  class Aws < Provider
    def self.credentials_keys; %w(AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY) end

    def self.services; %w(sms) end

    def client
      @client ||= ::Aws::SNS::Client.new(
        region: 'ap-southeast-1',
        access_key_id: access_key_id,
        secret_access_key: secret_access_key)
    end

    def access_key_id
      credentials_hash['AWS_ACCESS_KEY_ID'] || current_tenant.platform_twilio_enabled ? ENV['AWS_ACCESS_KEY_ID'] : nil
    end

    def secret_access_key
      credentials_hash['AWS_SECRET_ACCESS_KEY'] || current_tenant.platform_twilio_enabled ? ENV['AWS_SECRET_ACCESS_KEY'] : nil
    end

    # TODO: Get from provider
    def from; 'Prudential' end

    # TODO: toggle sending on and off
    def sms(message)
      message.update(from: from)
      client.set_sms_attributes({ attributes: { 'DefaultSenderID' => from } })
      res = client.publish(phone_number: message.to, message: message.body)
      p message
    # rescue
      # Rails.logger.warn('No Twilio client configured for tenant.account_id') and return if tenant.twilio_client.nil?
    end
  end
end
