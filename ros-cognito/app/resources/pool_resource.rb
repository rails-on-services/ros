# frozen_string_literal: true

class PoolResource < Cognito::ApplicationResource
  attributes :name, :properties
  has_many :users
end
