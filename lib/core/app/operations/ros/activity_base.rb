# frozen_string_literal: true

module Ros
  class ActivityBase < Trailblazer::Activity::Railway
    # NOTE: This is needed for the translating the errors object into
    # full messages
    def self.human_attribute_name(attr_name, _opts)
      attr_name.humanize
    end

    # NOTE: Wrapping call method around our Ros::OperationResult
    # This makes the activity base always return a result object
    # with the expected params
    def self.call(options)
      Ros::OperationResult.new(*super(options))
    end

    step :setup_context

    private

    def setup_context(ctx, _params)
      ctx[:errors] = ActiveModel::Errors.new(self)
    end

    class << self
      alias failed fail
    end
  end
end
