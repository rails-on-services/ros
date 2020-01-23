# frozen_string_literal: true

module Ros::Iam
  class PublicKeyResource < Iam::ApplicationResource
    attributes :content, :user_id
    has_one :user
  end
end
