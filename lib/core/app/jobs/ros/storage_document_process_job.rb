# frozen_string_literal: true

module Ros
  class StorageDocumentProcessJob < Ros::ApplicationJob
    def perform(*params)
      operation_class(*params).new.call(*params)
    end

    def operation_class(json)
      operation = JSON.parse(json)['operation']
      operation.constantize
    end
  end
end
