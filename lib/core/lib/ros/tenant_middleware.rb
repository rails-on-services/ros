# frozen_string_literal: true

require 'apartment/elevators/generic'

module Ros
  class TenantMiddleware < Apartment::Elevators::Generic
    attr_accessor :auth_string, :auth_type, :token, :access_key_id

    # Returns the schema_name for Apartment to switch to for this request
    def parse_tenant_name(request)
      @auth_string = request.env['HTTP_AUTHORIZATION']
      return 'public' unless auth_string.present?
      @auth_type, @token = auth_string.split(' ')
      @auth_type.downcase!
      Rails.logger.info("Invalid auth type #{auth_type}") and return 'public' unless auth_type.in? %w(basic bearer)
      Rails.logger.info('Invalid token') and return 'public' if token.nil?
      schema_name = send("tenant_name_from_#{auth_type}")
      Rails.logger.info('Invalid credentials') if schema_name.eql?('public')
      request.env['X-AccountId'] = schema_name
      Tenant.find_by(schema_name: schema_name)&.schema_name ||'public'
    end

    def tenant_name_from_basic
      return 'public' unless @access_key_id = token.split(':').first
      credential.try(:schema_name) || 'public'
    end

    def credential
      # TODO: Credential.authorization must be an instance variable
      Ros::Sdk::Credential.authorization = auth_string
      Ros::IAM::Credential.where(access_key_id: access_key_id).first
    # rescue JsonApiClient::Errors::ServerError => e
    # NOTE: Swallow the auth error and return nil which causes tenant to be 'public'
    rescue JsonApiClient::Errors::NotAuthorized => e
    end

    def tenant_name_from_bearer
      return 'public' unless account_id = urn.try(:account_id)
      Tenant.account_id_to_schema(account_id)
    end

    def urn; Urn.from_jwt(token) end

    # elsif Settings.service.auth_type
    # Ros::Sdk::Credential.authorization = "#{Settings.service.auth_type} #{token}"
    # Receiving request from another service
  end
end

=begin
module Ros
  class SomeTenantFromJWT < Apartment::Elevators::Generic
    def some_other_thing(request)
      # TODO: This only applies to IAM service so code goes there
      # Then only service agnostic code goes here
      return Tenant.public_schema if request.path.eql?('/roots/sign_in')
      if request.path.eql?('/users/sign_in')
        params = JSON.parse request.body.read
        request.body.rewind
        return Tenant.schema_name_from(account_id: params['account_id'])
      end
      # This code is for all services including IAM except for the endpoints above
      token = nil
      if request.env['HTTP_AUTHORIZATION']
        encryption_key = Rails.application.credentials.dig(:jwt, :encryption_key) || ENV['DEVISE_JWT_SECRET_KEY'] || 'test1234'
        # token = JWT.decode(request.env['HTTP_AUTHORIZATION'].split.last, encryption_key, 'HS256')
        token = JWT.decode(request.env['HTTP_AUTHORIZATION'].split.last, 'test1234', 'HS256')
      end
      return unless token
      urn_text = token[0]['urn']
      urn = Ros::Urn.new(urn_text)
      # TODO: Add the user's auth stuff here?
      # NOTE: It seems that the devise-jwt should take it from here and checks that the token is valid
      # All we are doing here is selecting the correct tenant based on the values in the token
      # Another question is: how is the current_user set
      # binding.pry
      Tenant.schema_name_from(account_id: urn.account_id)

      # return
      # return 'public' if request.path.starts_with?('/core')
      # return 'public' if request.path.starts_with?('/tenants')
      # return 'public' if request.path.starts_with?('/policies')
      # if request.path.eql?('/users/sign_in')
      #   body = request.body.read
      #   request.body.rewind
      #   # rescue JSON::ParserError => e
      #   binding.pry
      #   if access_key_id = JSON.parse(body)['access_key_id']
      #     aki = AccessKeyId.find_by(identifier: access_key_id).tenant.schema_name
      #     return aki
      #   end
      # else
      #   return 'test2'
      #   # rb = JSON.parse request.body.read
      #   # request.body.rewind
      #   # return rb['tenant']
      # end
      # Tenant.public_schema_endpoints.each do |path|
      #   return Tenant.public_schema if request.path.eql?(path)
      # end
      # token = JWT.decode(request.env['HTTP_AUTHORIZATION'].split.last, 'test1234', 'HS256')
      # token.first['tenant']
      # end
      # Tenant.set_request_store(request.env)
      # RequestStore.store[:tenant_request].schema_name
    end
  end
end
=end
