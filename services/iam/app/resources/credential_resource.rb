# frozen_string_literal: true

class CredentialResource < Iam::ApplicationResource
  attributes :access_key_id, :owner_type, :owner_id
  attributes :secret_access_key

  filter :access_key_id

  def self.descriptions
    {
      access_key_id: 'The access key'
    }
  end
end
