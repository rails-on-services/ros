# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone, :email, :primary_identifier, :properties
  filter :primary_identifier

  has_many :pools
end
