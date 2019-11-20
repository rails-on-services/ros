# frozen_string_literal: true

module Ros
  module ActivitySaver
    extend ActiveSupport::Concern
    PREFIX = 'save__'

    private

    def method_missing(method, ctx, *options, &blok)
      return super unless method.to_s.start_with? PREFIX

      save(ctx, model_name: method.to_s.remove(PREFIX), errors: ctx[:errors])
    end

    def respond_to_missing?(method, include_private = false)
      super || method.to_s.start_with?(PREFIX)
    end

    def save(ctx, model_name:, errors:)
      model = ctx[model_name.to_sym]
      raise ArgumentError, "missing keyword: #{model_name.to_sym}" unless model

      model.save!
    rescue ActiveRecord::RecordInvalid => e
      process_errors(e.record, errors)
      false
    end
  end
end
