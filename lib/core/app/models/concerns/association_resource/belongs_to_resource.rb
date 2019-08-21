# frozen_string_literal: true

module AssociationResource
  class BelongsToResource
    include ActiveModel::Model
    include AssociationInterface
    attr_reader :name, :class_name, :foreign_key, :polymorphic

    def initialize(name:, class_name:, foreign_key:, polymorphic: false)
      @name = name
      @class_name = class_name || name.to_s.classify
      @foreign_key = foreign_key || "#{name}_id"
      @polymorphic = polymorphic
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
      resource_klass = extract_resource_klass(model)
      resource_id = extract_resource_id(model)
      resource_klass.constantize.find(resource_id).first
    end
  end
end