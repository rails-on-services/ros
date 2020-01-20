# frozen_string_literal: true

module Ros
  module ApplicationRecordConcern
    extend ActiveSupport::Concern
    include AssociationResource
    include UrnConcern

    class_methods do
      def account_id; Apartment::Tenant.current.to_i end

      def current_tenant; Tenant.find_by(schema_name: Apartment::Tenant.current) end

      def resource_name; "#{service_name}::#{name}" end

      def service_name; Ros::Sdk.configured_services[Settings.service.name] end
    end

    included do
      def current_tenant; self.class.current_tenant end

      after_commit :stream_cloud_event, if: -> { Settings.event_logging.enabled }

      def stream_cloud_event
        type = "#{Settings.service.name}.#{self.class.name.underscore.downcase}"
        Ros::CloudEventStreamJob.perform_later(type: type, message_id: id, data: cloud_event_data)
      end

      def cloud_event_data
        attributes_to_modify = %i[jsonb datetime decimal]
        avro_attributes = attributes.map do |name, value|
          next [name, value] unless attributes_to_modify.include? column_for_attribute(name).type

          convert_attributes(name, value)
        end

        avro_attributes.to_h.merge('urn' => to_urn, '_op' => type_of_callback_trigger)
      end

      def convert_attributes(name, value)
        if column_for_attribute(name).type == :jsonb
          [name, value.to_s]
        elsif column_for_attribute(name).type == :datetime
          [name, (value.to_f * 1000).to_i]
        elsif column_for_attribute(name).type == :decimal
          [name, value.to_s('F')]
        end
      end

      def type_of_callback_trigger
        triggered_action = 'update'

        %i[create update destroy].each do |action|
          triggered_action = action.to_s if transaction_include_any_action?([action])
        end

        triggered_action
      end
    end
  end
end
