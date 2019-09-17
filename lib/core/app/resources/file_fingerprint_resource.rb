# frozen_string_literal: true

class FileFingerprintResource < JSONAPI::Resource
  attributes :model_name, :model_columns
  paginator :none
end
