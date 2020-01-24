# frozen_string_literal: true

module Ros
  class TenantCreateConsumer < ApplicationConsumer
    def consume
      params_batch.each do |params|
        schema_name = params['payload']['record']['schema_name']
        if Tenant.exists?(schema_name: schema_name)
          Rails.logger.warn "[#{Settings.service.name}] TenantCreate received existing tenant #{schema_name}"
          next
        end

        new_tenant = Tenant.create(schema_name: schema_name)
        next if new_tenant.persisted?

        Rails.logger.error "[#{Settings.service.name}] TenantCreate failed to create tenant #{new_tenant.errors.full_messages}"
      end
    end
  end
end
