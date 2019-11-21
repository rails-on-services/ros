# frozen_string_literal: true

module Ros
  module ActivityParamsValidator
    extend ActiveSupport::Concern
    VALIDATOR_NAME = 'ParamsValidator'
    delegate :validator, to: :class

    private

    def validate_required_params(ctx, errors:, **)
      return true unless validator

      validator.new(**ctx[:params]).validate!
    rescue ActiveModel::ValidationError => e
      process_errors(e.model, errors)
      false
    end

    class_methods do
      def required_params(*fields)
        return if fields.empty?
        return if validator.present?

        klass_name = VALIDATOR_NAME
        klass = const_set(klass_name, OpenStruct)
        klass.include(ActiveModel::Model).validates(*fields, presence: true)
      end

      def validator
        return unless constants.include? VALIDATOR_NAME.to_sym

        const_get VALIDATOR_NAME
      end
    end
  end
end
