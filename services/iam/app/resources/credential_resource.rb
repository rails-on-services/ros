# frozen_string_literal: true

class CredentialResource < Iam::ApplicationResource
  attributes :access_key_id, :owner_type, :owner_id, :secret_access_key,
             :account_id

  filter :access_key_id

  before_save do
    @model.owner ||= context[:user] unless Apartment::Tenant.current == 'public' && context[:user].root?
  end

  def account_id=(account_id)
    return unless account_id

    tenant = Tenant.find_by_schema_or_alias(account_id)
    Apartment::Tenant.switch(tenant.schema_name) do
      @model.owner = Root.first
    end
  end

  def self.creatable_fields(context)
    if Apartment::Tenant.current == 'public' && context[:user].root?
      [:account_id]
    else
      []
    end
  end

  def fetchable_fields
    super - %i[account_id]
  end

  def self.descriptions
    {
      access_key_id: 'The access key'
    }
  end
end
