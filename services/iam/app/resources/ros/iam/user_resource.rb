# frozen_string_literal: true

module Ros::Iam
  class UserResource < Iam::ApplicationResource
    attributes :username, :api, :console, :time_zone, :properties,
              :display_properties, :jwt_payload, :attached_policies,
              :attached_actions, :email, :password, :password_confirmation, :unconfirmed_email

    has_many :groups
    has_many :credentials
    has_many :public_keys

    filters :username, :groups

    def fetchable_fields
      super - %i[password password_confirmation]
    end

    def self.creatable_fields(context)
      super - %i[attached_policies attached_actions jwt_payload]
    end

    def self.updatable_fields(context)
      super - %i[attached_policies attached_actions jwt_payload]
    end
  end
end
