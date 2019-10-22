# frozen_string_literal: true

module Comm
  class ApplicationJob < Ros::ApplicationJob
    # NOTE: Temporarily living here until we have the parent class
    # handling the jobs and invoking the operations
    queue_as :comm_default

    # NOTE: perform, in order to interact with TRB operation, needs to
    # pass the params as an hash
    def perform(params)
      OperationResult.new(*operation_class.call(params))
    end

    private

    def operation_class
      operation_class_name = self.class.name
      operation_class_name.slice!('Job')
      operation_class_name.constantize
    end
  end
end
