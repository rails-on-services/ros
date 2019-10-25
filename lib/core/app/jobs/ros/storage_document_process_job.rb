# frozen_string_literal: true

module Ros
  class StorageDocumentProcessJob < Ros::ApplicationJob
    def perform(*params)
      operation_class(*params).new.call(*params)
    end
  end
end
