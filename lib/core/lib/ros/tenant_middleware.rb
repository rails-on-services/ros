# frozen_string_literal: true

require 'apartment/elevators/generic'

module Ros
  class TenantMiddleware < Apartment::Elevators::Generic
    attr_accessor :auth_type, :token, :access_key_id

    # Returns the schema_name for Apartment to switch to for this request
    def parse_tenant_name(request)
      @request = request
      parse_auth_type_and_token
      return 'public' unless auth_type_valid? && token_valid?

      schema_name = send("tenant_name_from_#{auth_type}")

      request.env['X-AccountId'] = schema_name
      Tenant.find_by(schema_name: schema_name)&.schema_name || 'public'
    end

    def tenant_name_from_basic
      return 'public' unless (@access_key_id = token.split(':').first)

      credential.try(:schema_name) || 'public'
    end

    def credential
      # TODO: Credential.authorization must be an instance variable
      Ros::Sdk::Credential.authorization = auth_string
      Ros::IAM::Credential.where(access_key_id: access_key_id).first
    # rescue JsonApiClient::Errors::ServerError => e

    # NOTE: Swallow the auth error and return nil which causes tenant to be 'public'
    rescue JsonApiClient::Errors::NotAuthorized
      nil
    end

    def tenant_name_from_bearer
      account_id = urn.try(:account_id)
      return Tenant.account_id_to_schema(account_id) if account_id

      Rails.logger.info('Invalid credentials')
      'public'
    end

    def auth_string
      @auth_string ||= @request.env['HTTP_AUTHORIZATION']
    end

    def urn; Urn.from_jwt(token) end

    private

    def parse_auth_type_and_token
      return if auth_string.blank?

      @auth_type, @token = auth_string.split(' ')
      @auth_type.downcase!
    end

    def auth_type_valid?
      return true if auth_type.in? %w[basic bearer]

      Rails.logger.info("Invalid auth type #{auth_type}")
      false
    end

    def token_valid?
      return true unless token.nil?

      Rails.logger.info('Invalid token')
      false
    end
  end
end
