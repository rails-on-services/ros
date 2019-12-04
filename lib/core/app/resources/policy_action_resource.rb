# frozen_string_literal: true

class PolicyActionResource < JSONAPI::Resource
  attributes :name, :actions
  paginator :none
end
