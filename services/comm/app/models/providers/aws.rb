# frozen_string_literal: true

module Providers
  class Aws < Provider
    alias_attribute :access_key_id, :credential_1
    alias_attribute :secret_access_key, :credential_2

    def self.services
      %w[sms]
    end

    def client
      return unless x_access_key_id && x_secret_access_key

      # TODO: Determine if dev or prod (prod should not have endpoint seti)
      @client ||= ::Aws::SNS::Client.new(region: 'ap-southeast-1',
                                         access_key_id: access_key_id,
                                         secret_access_key: secret_access_key,
                                         endpoint: 'http://localstack:4575')
    end

    def x_access_key_id
      access_key_id || current_tenant.platform_aws_enabled ? ENV['AWS_ACCESS_KEY_ID'] : nil
    end

    def x_secret_access_key
      secret_access_key || current_tenant.platform_aws_enabled ? ENV['AWS_SECRET_ACCESS_KEY'] : nil
    end

    # TODO: Get from provider
    def from
      'Prudential'
    end

    # TODO: toggle sending on and off
    def sms(to, body)
      # TODO: toggle sending on and off
      return unless Settings.active

      # message.update(from: from)
      client.set_sms_attributes(attributes: { 'DefaultSenderID' => from })
      client.publish(phone_number: to, message: body)
      # rescue
      # Rails.logger.warn('No AWS client configured for tenant.account_id') and return if client.nil?
    end
  end
end
