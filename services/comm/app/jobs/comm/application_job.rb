# frozen_string_literal: true

module Comm
  class ApplicationJob < ::ApplicationJob
    # NOTE: Temporarily living here until we have the parent class
    # handling the jobs and invoking the operations
    queue_as :comm_default

    def perform(*args)
      operation_class.call(args)
    end

    private

    def operation_class
      operation_class_name = self.class.name
      operation_class_name.slice!('Job')
      operation_class_name.constantize
    end
  end
end
