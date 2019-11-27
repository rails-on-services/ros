# frozen_string_literal: true

module Ros
  module ActivityParamsValidator
    extend ActiveSupport::Concern
    VALIDATOR_NAME = 'ParamsValidator'
    delegate :validator, :validator_fields, to: :class

    private

    def validate_required_params(ctx, errors:, **)
      return true unless validator
      return if validator_fields.blank?

      if ctx[:params].nil?
        errors.add(:params, ':params key is missing')
        return false
      end

      validator.new(**ctx[:params]).validate!
    rescue ActiveModel::ValidationError => e
      process_errors(e.model, errors)
      false
    end

    class_methods do
      def required_params(*fields)
        return if fields.empty?
        return if validator.present?

        @validator_fields = fields

        klass_name = VALIDATOR_NAME
        klass = const_set(klass_name, Class.new(OpenStruct))
        klass.include(ActiveModel::Validations).validates(*fields, presence: true)
      end

      def validator
        return unless constants.include? VALIDATOR_NAME.to_sym

        const_get VALIDATOR_NAME
      end

      def validator_fields
        @validator_fields
      end
    end
  end
end
