# frozen_string_literal: true

require 'apartment/elevators/generic'

module Ros
  class TenantMiddleware < Apartment::Elevators::Generic
    attr_accessor :auth_string, :auth_type, :token, :access_key_id

    # rubocop:disable Metrics/CyclomaticComplexity
    # Returns the schema_name for Apartment to switch to for this request
    def parse_tenant_name(request)
      @auth_string = request.env['HTTP_AUTHORIZATION']
      return 'public' if auth_string.blank?

      @auth_type, @token = auth_string.split(' ')
      @auth_type.downcase!
      Rails.logger.info("Invalid auth type #{auth_type}") && (return 'public') unless auth_type.in? %w[basic bearer]
      Rails.logger.info('Invalid token') && (return 'public') if token.nil?
      schema_name = send("tenant_name_from_#{auth_type}")
      Rails.logger.info('Invalid credentials') if schema_name.eql?('public')
      request.env['X-AccountId'] = schema_name
      Tenant.find_by(schema_name: schema_name)&.schema_name || 'public'
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def tenant_name_from_basic
      return 'public' unless (@access_key_id = token.split(':').first)

      credential.try(:schema_name) || 'public'
    end

    # rubocop:disable Lint/HandleExceptions
    def credential
      # TODO: Credential.authorization must be an instance variable
      Ros::Sdk::Credential.authorization = auth_string
      Ros::IAM::Credential.where(access_key_id: access_key_id).first
    # rescue JsonApiClient::Errors::ServerError => e
    # NOTE: Swallow the auth error and return nil which causes tenant to be 'public'
    rescue JsonApiClient::Errors::NotAuthorized
    end
    # rubocop:enable Lint/HandleExceptions

    def tenant_name_from_bearer
      return 'public' unless (account_id = urn.try(:account_id))

      Tenant.account_id_to_schema(account_id)
    end

    def urn; Urn.from_jwt(token) end
  end
end
