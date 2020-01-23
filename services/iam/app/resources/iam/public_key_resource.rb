# frozen_string_literal: true

module Iam
  class PublicKeyResource < Iam::ApplicationResource
    attributes :content, :user_id
    has_one :user
  end
end
