# frozen_string_literal: true

class TenantResource < Ros::ApplicationResource
  # attributes :account_id, :alias, :name, :schema_name # :locale
  attributes :schema_name, :properties
end
