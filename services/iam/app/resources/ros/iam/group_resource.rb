# frozen_string_literal: true

module Ros::Iam
  class GroupResource < Iam::ApplicationResource
    attributes :name
    has_many :users

    filter :name
  end
end
