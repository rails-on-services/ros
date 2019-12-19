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

      @client ||= ::Aws::SNS::Client.new(client_params)
    end

    def x_access_key_id
      access_key_id || current_tenant.platform_aws_enabled ? ENV['AWS_ACCESS_KEY_ID'] : nil
    end

    def x_secret_access_key
      secret_access_key || current_tenant.platform_aws_enabled ? ENV['AWS_SECRET_ACCESS_KEY'] : nil
    end

    def from
      current_tenant.properties.dig(:from) || 'Perx'
    end

    def sms(to, body)
      client.set_sms_attributes(attributes: { 'DefaultSenderID' => from })
      client.publish(phone_number: to, message: body)
    rescue ::Aws::SNS::Errors::ServiceError => e
      Rails.logger.warn("No AWS client configured for tenant.account_id. #{e.inspect}")
    end

    private

    # TODO: Cleanup this logic. This should probably live in an initializer.
    # The problem might be that a tenant uses Perx SNS credentials for sending
    # the sms but then wants to use his own credentials for storing the assets
    # in the S3. We should have the configuration being picked up from
    # 1. settings, env variables, our defaults
    def client_params
      params = { region: 'ap-southeast-1',
                 access_key_id: x_access_key_id,
                 secret_access_key: x_secret_access_key }

      params[:endpoint] = ENV['AWS_ENDPOINT'] unless ENV['AWS_ENDPOINT'].nil?
      params
    end
  end
end
