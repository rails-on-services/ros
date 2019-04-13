# frozen_string_literal: true

class UserResource < Cognito::ApplicationResource
  attributes :title, :first_name, :last_name, :phone_number, :email_address, :primary_identifier, :properties
  filter :primary_identifier
end
