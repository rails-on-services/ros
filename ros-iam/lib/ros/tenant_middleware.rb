# frozen_string_literal: true

module Ros
  class TenantMiddleware
    # NOTE: Overrides method in ros-core gem
    def credential
      Credential.access_key_id_to_schema_name(access_key_id)
    end
  end
end
