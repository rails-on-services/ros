# frozen_string_literal: true

class UserResource < Iam::ApplicationResource
  attributes :username, :api, :console, :time_zone, :properties,
             :display_properties, :jwt_payload, :attached_policies,
             :attached_actions, :email
  has_many :groups
  has_many :credentials

  filter :username

  def self.creatable_fields(context)
    super - %i[attached_policies attached_actions jwt_payload]
  end

  def self.updatable_fields(context)
    super - %i[attached_policies attached_actions jwt_payload]
  end
end
