# frozen_string_literal: true

module Storage
  class ApplicationController < ::ApplicationController

    def current_storage
      @storage ||= UploadStorage.find_or_create!
    end

    def json_resources(klass, records, context = nil)
      resource = records.map { |record| klass.new(record, context) }
      serialize_resource(klass, resource)
    end

    def json_resource(klass, record, context = nil)
      resource = klass.new(record, context)
      serialize_resource(klass, resource)
    end

    private

    def serialize_resource(klass, resource)
      JSONAPI::ResourceSerializer.new(klass).serialize_to_hash(resource)
    end
  end
end
