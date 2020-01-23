# frozen_string_literal: true

module Ros::Iam
  class PolicyResource < Iam::ApplicationResource
    # caching
    attributes :name
    filter :name

    has_many :actions
  end
end
