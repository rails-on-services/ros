# frozen_string_literal: true

module Comm
  class ApplicationJob < ::ApplicationJob
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

# TODO: This has to be moved somewhere else. If we don't want to use the
# TRB activity's multiple outcomes capabilities, we can rely on the
# TRB operation that already provides a result class that handles all
# the logic for this. Nevertheless I think it might be useful to have our
# operations using activity rather than
class OperationResult
  attr_reader :errors

  def initialize(*args)
    @end_signal = args[0]
    @ctx = args[1][0]
    @flow_props = args[1][1]
    @errors = []
    parse_errors
  end

  def failure?
    %i[fail_fast failure].include? @end_signal.to_h[:semantic]
  end

  def success?
    %i[pass_fast success].include? @end_signal.to_h[:semantic]
  end

  private

  def parse_errors
    @errors += @ctx[:errors] if @ctx[:errors].present?

    if (errors = @ctx[:model]&.errors&.full_messages)
      @errors += errors
    end
    @errors.compact
  end
end
