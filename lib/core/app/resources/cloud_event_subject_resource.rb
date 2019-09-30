# frozen_string_literal: true

class CloudEventSubjectResource < JSONAPI::Resource
  attributes :model_name
  paginator :none
end
