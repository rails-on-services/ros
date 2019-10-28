# frozen_string_literal: true

class PublicKeyResource < Iam::ApplicationResource
  attributes :content, :user_id
  has_one :user
end
