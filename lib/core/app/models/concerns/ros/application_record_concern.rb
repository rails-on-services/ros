# frozen_string_literal: true

module Ros
  module ApplicationRecordConcern
    extend ActiveSupport::Concern
    include AssociationResource
    include UrnConcern

    class_methods do
      def account_id; Apartment::Tenant.current.eql?('public') ? '' : Apartment::Tenant.current.remove('_') end

      def current_tenant; Tenant.find_by(schema_name: Apartment::Tenant.current) end

      def resource_name; "#{service_name}::#{name}" end

      def service_name; Ros::Sdk.configured_services[Settings.service.name] end
    end

    included do
      def current_tenant; self.class.current_tenant end

      after_commit :stream_cloud_event, if: -> { Settings.event_logging.enabled }

      def stream_cloud_event
        type = "#{Settings.service.name}.#{self.class.name.underscore}"
        Ros::StreamCloudEventJob.perform_later(type, id, cloud_event_data)
      end

      def cloud_event_data
        attributes_to_modify = %i[jsonb datetime]
        avro_attributes = attributes.map do |name, value|
          next [name, value] unless attributes_to_modify.include? column_for_attribute(name).type

          convert_attributes(name, value)
        end

        avro_attributes.to_h.merge('urn' => to_urn)
      end

      def convert_attributes(name, value)
        if column_for_attribute(name).type == :jsonb
          [name, value.to_s]
        elsif column_for_attribute(name).type == :datetime
          [name, (value.to_f * 1000).to_i]
        end
      end
    end
  end
end
