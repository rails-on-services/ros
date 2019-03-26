# frozen_string_literal: true

module Ros
  class ApplicationResource < JSONAPI::Resource
    include JSONAPI::Authorization::PunditScopedResource
    abstract
    attributes :urn

    def urn; @model.to_urn end

    # def meta(options)
    #   {
    #     copyright: 'API Copyright 2015 - XYZ Corp.',
    #     computed_copyright: options[:serialization_options][:copyright],
    #     last_updated_at: _model.updated_at
    #   }
    # end
  end
end
