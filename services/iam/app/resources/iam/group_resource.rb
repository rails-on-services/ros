# frozen_string_literal: true

module Iam
  class GroupResource < Iam::ApplicationResource
    attributes :name
    has_many :users

    filter :name
  end
end
