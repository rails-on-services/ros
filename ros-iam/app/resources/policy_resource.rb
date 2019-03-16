# frozen_string_literal: true

class PolicyResource < Iam::ApplicationResource
  # caching
  attributes :name
  filter :name

  has_many :actions
end
