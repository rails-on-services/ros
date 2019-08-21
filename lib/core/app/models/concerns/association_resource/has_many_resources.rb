# frozen_string_literal: true

module AssociationResource
  class HasManyResources
    include ActiveModel::Model
    include AssociationInterface
    attr_reader :name, :class_name, :foreign_key, :associated_name

    def initialize(name:, class_name:, foreign_key:, associated_name:)
      @name = name
      @class_name = class_name || name.to_s.classify
      @foreign_key = foreign_key

      @associated_name = associated_name # Is not working yet
    end

    private

    def persisted_resource?(model)
      return if model_resource(model).blank?

      resource_id = model.id
      id_column = id_column(model)
      model_resource(model).map(&id_column.to_sym).all? resource_id.to_s
    end

    def id_column(model)
      column = foreign_key || "#{model.class.to_s.underscore}_id"
      return column #if associated_name.blank?

      "#{associated_name}_id"
    end

    def type_column
      # @TODO find a way to get a propper type "Ros::Iam::User" from "User" model
      return #if associated_name.blank?

      "#{associated_name}_type"
    end

    def query_resource(model)
      id_column = id_column(model)
      query = class_name.constantize.where(id_column => model.id)
      query = query.where(type_column => model.class.name) unless type_column.blank?

      query.find
    end
  end
end