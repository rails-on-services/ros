# frozen_string_literal: true

module Ros::Iam
  class GroupResource < Ros::Iam::ApplicationResource
    attributes :name
    has_many :users

    filter :name
  end
end
