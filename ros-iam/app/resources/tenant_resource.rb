# frozen_string_literal: true

class TenantResource < Iam::ApplicationResource
  attributes :account_id, :alias, :name # :locale
end
