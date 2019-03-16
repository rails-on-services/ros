# frozen_string_literal: true

module Ros
  class ApplicationResource < JSONAPI::Resource
    include JSONAPI::Authorization::PunditScopedResource
    abstract
    attributes :urn

    def urn; @model.to_urn end
  end
end
