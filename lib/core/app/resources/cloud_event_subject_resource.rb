# frozen_string_literal: true

class CloudEventSubjectResource < JSONAPI::Resource
  attributes :name
  paginator :none
end
