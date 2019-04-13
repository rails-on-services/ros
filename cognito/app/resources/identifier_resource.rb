# frozen_string_literal: true

class IdentifierResource < Cognito::ApplicationResource
  attributes :name, :value, :properties
  has_one :user
end
