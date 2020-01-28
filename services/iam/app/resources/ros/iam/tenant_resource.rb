# frozen_string_literal: true

module Ros
  module Iam
    class TenantResource < Ros::Iam::ApplicationResource
      attributes :account_id, :root_id, :alias, :name, :display_properties # :locale

      filter :schema_name

      def self.descriptions
        {
          schema_name: 'The name of the <h1>Schema</h1>'
        }
      end

      def self.updatable_fields(context)
        super - [:root_id]
      end

      def self.creatable_fields(context)
        super - [:root_id]
      end
    end
  end
end
