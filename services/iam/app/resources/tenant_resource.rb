# frozen_string_literal: true

class TenantResource < Iam::ApplicationResource
  attributes :account_id, :root_id, :alias, :name, :properties # :locale

  filter :schema_name

  def self.descriptions
    {
      schema_name: 'The name of the <h1>Schema</h1>'
    }
  end

  def self.updatable_fields(context)
    super - [:root_id]
  end

  def self.creatable_fields(context)
    super - [:root_id]
  end
end
