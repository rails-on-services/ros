# frozen_string_literal: true

# TODO: If we don't want to use the TRB activity's multiple outcomes
# capabilities, we can rely on the TRB operation that already provides a result
# class that handles all the logic for this. Nevertheless I think it might be
# useful to have our operations using activity rather than Operation
class Result
  # extend ActiveModel::Naming

  attr_reader :errors

  def initialize(*args)
    @end_signal = args[0]
    @ctx = args[1][0]
    @flow_props = args[1][1]
    @errors = ActiveModel::Errors.new(self)
    parse_errors
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

  private

  def parse_errors
    @ctx[:errors].each do |error|
      key = error.keys.first
      @errors.add(key, error[key])
    end
  end
end
