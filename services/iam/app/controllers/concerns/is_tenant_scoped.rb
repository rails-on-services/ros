# frozen_string_literal: true

module IsTenantScoped
  extend ActiveSupport::Concern

  def login_user!
    false
  end

  def tenant_schema
    tenant&.schema_name || Apartment::Tenant.current
  end

  def user_resource
    "#{resource_name.capitalize}Resource".constantize
  end
end
