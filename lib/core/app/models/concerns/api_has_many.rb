# frozen_string_literal: true

module ApiHasMany
  extend ActiveSupport::Concern

  class_methods do

    def api_has_many(models, class_name: nil, foreign_key: nil, where: nil)
      foreign_key_column = foreign_key || "#{class_name ? class_name.underscore : models.to_s.singularize}_id"

      class_name ||= models.singularize.to_s.classify
      class_type = class_name.constantize
      # attr_accessor models

      define_method(models) do
        instance_variable_get("@#{models}") || (
          where = {}
          where[foreign_key_column.to_sym] = id
          instance_variable_set("@#{models}", class_type.send(:where, where))
        )
      end
    end
  end
end
