# frozen_string_literal: true

module Ros
  module UrnConcern
    extend ActiveSupport::Concern

    class_methods do
      # urn:partition:service:region:account_id:resource_type
      def to_urn
        "#{urn_base}:#{account_id}:#{name.underscore}"
      end

      # Universal Resource Name (URNs) and Service Namespaces
      # urn:partition:service:region
      def urn_base
        "urn:#{Settings.partition_name}:#{Settings.service.name}:#{Settings.region}"
      end

      def find_by_urn(value)
        find_by(urn_id => value)
      end

      # NOTE: Override in model to provide a custom id
      def urn_id
        :id
      end
    end

    included do
      # urn:partition:service:region:account_id:resource_type/id
      def to_urn
        "#{self.class.to_urn}/#{send(self.class.urn_id)}"
      end

      def as_json(*)
        super.merge('urn' => to_urn)
      end
    end
  end
end
