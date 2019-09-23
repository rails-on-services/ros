# frozen_string_literal: true

module AssociationResource
  module AssociationInterface
    attr_reader :name

    def call(model)
      model.instance_variable_set "@#{name}", query_resource(model) unless persisted_resource? model

      model_resource(model)
    end

    def _resource_class
      class_name.safe_constantize
    end

    def model_resource(model)
      model.instance_variable_get "@#{name}"
    end

    def persisted_resource?(model)
      false
    end

    def query_resource(model)
      raise NotImplementedError, ':query_resource should be implemented'
    end
  end
end
