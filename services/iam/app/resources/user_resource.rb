# frozen_string_literal: true

class UserResource < Iam::ApplicationResource
  attributes :username, :api, :console, :time_zone
  attributes :properties, :display_properties
  attributes :jwt_payload, :attached_policies, :attached_actions, :actions

  has_many :groups
  has_many :credentials
  has_many :public_keys

  filters :username, :groups

  def self.creatable_fields(context)
    super - %i[attached_policies attached_actions jwt_payload]
  end

  def self.updatable_fields(context)
    super - %i[attached_policies attached_actions jwt_payload]
  end

  def actions
    @model.actions
  end
end
