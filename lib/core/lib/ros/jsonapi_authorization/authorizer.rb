# frozen_string_literal: true

module Ros
  module JsonapiAuthorization
    class Authorizer < JSONAPI::Authorization::DefaultPunditAuthorizer
      def include_has_many_resource(source_record:, record_class:)
        source_class = source_record.class
        inner_associations = source_class.reflect_on_all_associations(:has_many).map(&:class_name)
        return unless inner_associations.include? related_record.class.name

        binding.pry
        super
      end

      def include_has_one_resource(source_record:, related_record:)
        source_class = source_record.class
        inner_associations = source_class.reflect_on_all_associations(:belongs_to).map(&:class_name)
        inner_associations += source_class.reflect_on_all_associations(:has_one).map(&:class_name)
        return unless inner_associations.include? related_record.class.name

        super
      end
    end
  end
end
