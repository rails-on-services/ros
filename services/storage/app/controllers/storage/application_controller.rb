# frozen_string_literal: true

module Storage
  class ApplicationController < ::ApplicationController

    def current_storage
      @storage ||= UploadStorage.find_or_create!
    end

    def json_resources(klass, records, context = nil)
      resources = records.map { |record| klass.new(record, context) }
      JSONAPI::ResourceSerializer.new(klass).serialize_to_hash(resources)
    end
  end
end
