# frozen_string_literal: true

module IsTenantScoped
  extend ActiveSupport::Concern

  def login_user!
    false
  end

  def tenant_schema(params, key = :account_id)
    params_ = HashWithIndifferentAccess.new(params)

    # this is not a dynamically created method but defined in our tenant concern
    Tenant.find_by_schema_or_alias(params_[key])&.schema_name ||
      Apartment::Tenant.current
  end

  def user_resource
    "#{resource_name.capitalize}Resource".constantize
  end
end
