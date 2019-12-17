# frozen_string_literal: true

# Class Represents external association ONE_ONE
module AssociationResource
  class HasOneResource < HasManyResources

    def query_resource(model)
      result = super
      result.first
    end

    private

    def persisted_resource?(model)
      return if model_resource(model).blank?

      resource_id = model.id
      id_column = id_column(model)

      model_resource(model)&.send(id_column.to_sym) == resource_id.to_s
    end
  end
end
