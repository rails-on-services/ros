# frozen_string_literal: true

module AssociationResource
  module ResourceHelper
    extend ActiveSupport::Concern

    class_methods do
      def preload_included_fragments(resources, records, serializer, options)
        return if resources.empty?

        include_directives = options[:include_directives]
        return unless include_directives

        array_includes = include_directives.include_directives[:include_related]
        resources_array = array_includes.select { |res| _model_class.find_resource(res) }

        # Exclude non active-record includes
        array_includes.except!(*resources_array.keys)
        super
        # return non active-record includes
        array_includes.merge!(resources_array)
      end

      def belongs_to_resource(resource)
        has_one resource.to_sym, class_name: 'AssociationResource::Included'
      end

      # rubocop:disable Naming/PredicateName
      def has_many_resources(resources)
        has_many resources.to_sym, class_name: 'AssociationResource::Included'

        define_method("records_for_#{resources}") { |_| _model.send(resources.to_sym) }
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
