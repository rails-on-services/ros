# frozen_string_literal: true

class ServicePolicyResource < JSONAPI::Resource
  attributes :name, :description, :version, :rules
  paginator :none
end
