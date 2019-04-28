# frozen_string_literal: true

class GroupResource < Iam::ApplicationResource
  attributes :name
  has_many :users

  filter :name
end


