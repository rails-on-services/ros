# frozen_string_literal: true

# TODO: If we don't want to use the TRB activity's multiple outcomes
# capabilities, we can rely on the TRB operation that already provides a result
# class that handles all the logic for this. Nevertheless I think it might be
# useful to have our operations using activity rather than Operation
module Ros
  class OperationResult
    attr_reader :errors

    def initialize(signal, context)
      @end_signal = signal
      @ctx = context[0]
      @flow_props = context[1]
      @errors = @ctx[:errors]
    end

    def model
      @ctx[:model]
    end

    def failure?
      %i[fail_fast failure].include? @end_signal.to_h[:semantic]
    end

    def success?
      %i[pass_fast success].include? @end_signal.to_h[:semantic]
    end
  end
end
