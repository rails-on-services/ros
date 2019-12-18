# frozen_string_literal: true

module Ros
  class PlatformEventProcessJob < Ros::ApplicationJob
    def operation_class(json)
      operation = JSON.parse(json)['operation']
      operation.constantize
    end
  end
end
