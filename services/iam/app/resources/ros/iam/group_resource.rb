# frozen_string_literal: true

module Ros
  module Iam
    class GroupResource < Ros::Iam::ApplicationResource
      attributes :name
      has_many :users

      filter :name
    end
  end
end
