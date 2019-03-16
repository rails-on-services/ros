# frozen_string_literal: true

class GroupResource < Iam::ApplicationResource
  attributes :name

  filter :name
end


