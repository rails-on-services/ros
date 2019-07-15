# frozen_string_literal: true

class RootResource < Iam::ApplicationResource
  attributes :email, :jwt_payload

  filter :email
  # has_many :credentials
end
