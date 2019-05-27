# frozen_string_literal: true

class UserResource < Iam::ApplicationResource
  attributes :username, :api, :console, :time_zone
  attributes :properties, :display_properties
  attributes :jwt_payload, :attached_policies, :attached_actions

  has_many :groups
  has_many :credentials

  filter :username

  def self.creatable_fields(context)
    super - %i(attached_policies attached_actions)
  end

  def self.updatable_fields(context)
    super - %i(attached_policies attached_actions)
  end
end

