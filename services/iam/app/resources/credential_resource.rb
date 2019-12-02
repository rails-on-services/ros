# frozen_string_literal: true

class CredentialResource < Iam::ApplicationResource
  attributes :access_key_id, :owner_type, :owner_id, :secret_access_key,
             :account_id

  filter :access_key_id

  def account_id=(account_id)
    return unless account_id

    tenant = Tenant.find_by_schema_or_alias(account_id)
    @model.owner = tenant.root
  end

  def self.creatable_fields(context)
    if Apartment::Tenant.current == 'public' && context[:user].root?
      [:account_id]
    else
      %i[owner_type owner_id]
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
