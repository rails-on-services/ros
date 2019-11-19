# frozen_string_literal: true

class PoolResource < Cognito::ApplicationResource
  attributes :name, :properties
  has_many :users

  filter :name, apply: lambda { |records, value, _options|
    records.where('name ILIKE ?', "%#{value[0]}%")
  }
end
