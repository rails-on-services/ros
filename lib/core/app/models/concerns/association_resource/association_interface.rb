# frozen_string_literal: true

# Interface represents main logic of querying external association
module AssociationResource
  module AssociationInterface
    attr_reader :name

    def call(model)
      model.instance_variable_set "@#{name}", query_resource(model) unless persisted_resource? model

      model_resource(model)
    end

    def _resource_class(_model)
      class_name.safe_constantize
    end

    def model_resource(model)
      model.instance_variable_get "@#{name}"
    end

    def persisted_resource?(_model)
      false
    end

    def query_resource(_model)
      raise NotImplementedError, ':query_resource should be implemented'
    end
  end
end
