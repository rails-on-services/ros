module Ros
  module ActivityValidator
    extend ActiveSupport::Concern

    private

    def validate_required(_ctx, params:, errors:)
      return true unless validator

      validator.new(params).validate!
    rescue ActiveModel::ValidationError => e
      process_errors(e.model, errors)
      false
    end

    def validator
      self.class.instance_variable_get :@validator
    end

    class_methods do
      def required_fields(*fields)
        return if fields.empty?

        klass = OpenStruct.include(ActiveModel::Model)
        klass.validates(*fields, presence: true)
        @validator = klass
      end
    end
  end
end
