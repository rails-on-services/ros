# frozen_string_literal: true

module IsTenantScoped
  extend ActiveSupport::Concern

  def login_user!
    false
  end

  # rubocop:disable Rails/DynamicFindBy
  def tenant_schema(params, key = :account_id)
    # this is not a dynamically created method but defined in our tenant concern
    Tenant.find_by_schema_or_alias(params[key])&.schema_name ||
      Apartment::Tenant.current
  end
  # rubocop:enable Rails/DynamicFindBy

  def user_resource
    "#{resource_name.capitalize}Resource".constantize
  end
end
