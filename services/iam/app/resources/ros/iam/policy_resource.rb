# frozen_string_literal: true

module Ros
  module Iam
    class PolicyResource < Ros::Iam::ApplicationResource
      # caching
      attributes :name
      filter :name

      has_many :actions
    end
  end
end
