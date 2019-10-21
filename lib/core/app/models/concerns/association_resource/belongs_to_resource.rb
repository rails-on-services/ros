# frozen_string_literal: true

# Class Represents external association ONE_ONE
module AssociationResource
  class BelongsToResource
    include ActiveModel::Model
    include AssociationInterface
    attr_reader :class_name, :foreign_key, :polymorphic

    def initialize(name:, class_name:, foreign_key:, polymorphic: false)
      @name = name
      @class_name = class_name || name.to_s.classify
      @foreign_key = foreign_key || "#{name}_id"
      @polymorphic = polymorphic
    end

    def _resource_class(model)
      extract_resource_klass(model).safe_constantize
    end

    private

    def persisted_resource?(model)
      return if model_resource(model).blank?

      resource_id = extract_resource_id(model)
      model_resource(model)&.id == resource_id.to_s
    end

    def extract_resource_klass(model)
      return class_name unless polymorphic

      model.send("#{name}_type")
    end

    def extract_resource_id(model)
      return model.send(foreign_key) unless polymorphic

      model.send("#{name}_id")
    end

    def query_resource(model)
      resource_klass = _resource_class(model)
      return unless resource_klass

      resource_id = extract_resource_id(model)
      resource_klass.where(id: resource_id).first
    end
  end
end
