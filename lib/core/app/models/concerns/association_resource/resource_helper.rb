# frozen_string_literal: true

module AssociationResource
  module ResourceHelper
    extend ActiveSupport::Concern

    # Overrided relationship method to return desired resource type
    # rubocop:disable Style/ClassAndModuleChildren
    class JSONAPI::Relationship
      def type_for_source(source)
        resource = source.public_send(name)
        return resource.class._type if resource.is_a? AssociationResource::IncludedResource

        type
      end
    end
    # rubocop:enable Style/ClassAndModuleChildren

    class_methods do
      def preload_included_fragments(resources, _records, _serializer, options)
        return if resources.empty?

        include_directives = options[:include_directives]
        return unless include_directives

        array_includes = include_directives.include_directives[:include_related]
        resources_array = array_includes.select { |res| _model_class.find_resource(res) }

        # Exclude non active-record includes
        array_includes.except!(*resources_array.keys)

        # return non active-record includes
        array_includes.merge!(resources_array)
      end

      def belongs_to_resource(resource)
        resource_name = resource.to_s.singularize
        define_new_resource(resource_name)
        has_one resource.to_sym, class_name: "AssociationResource::#{resource_name}"
      end

      # rubocop:disable Naming/PredicateName
      def has_many_resources(resources)
        resource_name = resources.to_s.singularize
        define_new_resource(resource_name)
        has_many resources.to_sym, class_name: "AssociationResource::#{resource_name}"
        define_method("records_for_#{resources}") { |_| _model.send(resources.to_sym) }
      end

      def has_one_resource(resource)
        resource_name = resource.to_s.singularize
        define_new_resource(resource_name)
        has_one resource.to_sym, class_name: "AssociationResource::#{resource_name}", foreign_key_on: :related
        define_method("record_for_#{resource}") { _model.send(resource.to_sym) }
      end
      # rubocop:enable Naming/PredicateName

      private

      # Dynamically define resource class for each external resource
      def define_new_resource(resource_name)
        name = resource_name.singularize
        resource_klass_name = name.to_s.camelcase
        klass_name = "#{resource_klass_name}Resource"
        return if AssociationResource.const_defined? klass_name

        base_klass = AssociationResource::IncludedResource
        base_klass.sub_name = name
        AssociationResource.const_set(klass_name, Class.new(base_klass))
      end
    end
  end
end
