# frozen_string_literal: true

module Ros
  class TenantUpdateConsumer < ApplicationConsumer
    def consume
      params_batch.each do |params|
        record = params['payload']['record']
        schema_name = record['schema_name']
        @tenant = Tenant.find_by(schema_name: schema_name)

        unless @tenant
          Rails.logger.error "[OUTCOME_SERVICE] TenantUpdate received tenant that does not exist #{schema_name}"
          raise 'Missing Tenant'
        end

        update_tenant(record)
      end
    end

    def update_tenant(data)
      # TODO: Add display properties to all tenants and fix this mapping
      @tenant.update!(
        platform_properties: data['properties'],
        properties: data['display_properties']
      )
    end
  end
end
