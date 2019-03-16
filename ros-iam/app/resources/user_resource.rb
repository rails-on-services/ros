# frozen_string_literal: true

class UserResource < Iam::ApplicationResource
  attributes :username, :jwt_payload, :attached_policies, :attached_actions

  filter :username

  # has_many :credentials
end

