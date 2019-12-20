# frozen_string_literal: true

module Ros
  class PlatformEventProcess
    def self.call(json)
      operation_class(json).call(json)
    end

    def operation_class(json)
      operation = JSON.parse(json)['operation']
      operation.constantize
    end
  end
end
