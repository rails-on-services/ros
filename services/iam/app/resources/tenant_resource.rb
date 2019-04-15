# frozen_string_literal: true

class TenantResource < Iam::ApplicationResource
  attributes :account_id, :alias, :name # :locale

  filter :schema_name

  def self.descriptions
    {
      schema_name: 'The name of the <h1>Schema</h1>'
    }
  end
end
