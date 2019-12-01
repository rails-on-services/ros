# frozen_string_literal: true

module Ros
  # NOTE: Overrides methods in ros-core gem
  class ApiTokenStrategy
    def authenticate_basic
      credential = if access_key[:owner_type].eql?('Root')
                     Apartment::Tenant.switch('public') { Credential.find_by(access_key_id: access_key_id) }
                   else
                     Credential.find_by(access_key_id: access_key_id)
                   end
      return unless credential

      credential.authenticate_secret_access_key(secret_access_key).try(:owner)
    end

    def authenticate_bearer
      return unless (urn = Urn.from_jwt(token))
      return unless urn.model_name.in? %w[Root User]

      urn.instance
    end
  end
end
