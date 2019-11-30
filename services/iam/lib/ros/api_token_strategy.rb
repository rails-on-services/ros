# frozen_string_literal: true

module Ros
  # NOTE: Overrides methods in ros-core gem
  class ApiTokenStrategy
    def authenticate_basic
      # TODO: Credentials need to be only in the tenant schema, not in public
      # NOTE: Is that still true that credentials should only be in tenant schema?
      schema_name = Ros::AccessKey.decode(access_key_id)[:schema_name]
      return unless (credential = Apartment::Tenant.switch(schema_name) do
        Credential.find_by(access_key_id: access_key_id)
      end)

      credential.authenticate_secret_access_key(secret_access_key).try(:owner)
    end

    def authenticate_bearer
      return unless (urn = Urn.from_jwt(token))
      return unless urn.model_name.in? %w[Root User]

      urn.instance
    end
  end
end
