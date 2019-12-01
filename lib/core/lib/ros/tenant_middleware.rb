# frozen_string_literal: true

require 'apartment/elevators/generic'

# rack = lambda { |env| [200, { 'Content-Type' => 'text/plain' }, ['OK']] }]}
# request = OpenStruct.new(env: {'HTTP_AUTHORIZATION' => 'Basic 1EWzOrRhxjlk9JtQON8b:test'})
# Ros::TenantMiddleware.new(rack).parse_tenant_name(request)

module Ros
  class TenantMiddleware < Apartment::Elevators::Generic
    attr_accessor :auth_type, :token

    # Returns the schema_name for Apartment to switch to for this request
    def parse_tenant_name(request)
      auth_string = request.env['HTTP_AUTHORIZATION']
      return 'public' if auth_string.blank?

      @auth_type, @token = auth_string.split(' ')
      auth_type.downcase!
      return 'public' unless auth_is_well_formed

      schema_name = send("tenant_name_from_#{auth_type}")
      request.env['X-AccountId'] = schema_name
      schema_name
    end

    def auth_is_well_formed
      if !auth_type.in?(%w[basic bearer])
        Rails.logger.info("Invalid auth type #{auth_type}")
      elsif token.nil?
        Rails.logger.info('Invalid token')
      else
        return true
      end
      false
    end

    def tenant_name_from_basic
      return 'public' unless (access_key_id = token.split(':').first)

      Ros::AccessKey.decode(access_key_id)[:schema_name]
    end

    def tenant_name_from_bearer
      urn = Urn.from_jwt(token)
      return 'public' unless (account_id = urn.try(:account_id))

      Tenant.account_id_to_schema(account_id)
    end
  end
end
