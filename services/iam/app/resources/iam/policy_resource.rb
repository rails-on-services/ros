# frozen_string_literal: true

module Iam
  class PolicyResource < Iam::ApplicationResource
    # caching
    attributes :name
    filter :name

    has_many :actions
  end
end
