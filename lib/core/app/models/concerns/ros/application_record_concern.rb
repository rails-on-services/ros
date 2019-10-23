# frozen_string_literal: true

module Ros
  module ApplicationRecordConcern
    extend ActiveSupport::Concern
    include AssociationResource

    class_methods do
      # urn:partition:service:region:account_id:resource_type
      # def self.to_urn; "#{urn_base}:#{current_tenant.try(:account_id)}:#{name.underscore}" end
      def to_urn; "#{urn_base}:#{account_id}:#{name.underscore}" end

      def account_id; Apartment::Tenant.current.eql?('public') ? '' : Apartment::Tenant.current.remove('_') end

      def current_tenant; Tenant.find_by(schema_name: Apartment::Tenant.current) end

      # Universal Resource Name (URNs) and Service Namespaces
      # urn:partition:service:region
      def urn_base; "urn:#{Settings.partition_name}:#{Settings.service.name}:#{Settings.region}" end

      def find_by_urn(value); find_by(urn_id => value) end

      # NOTE: Override in model to provide a custom id
      def urn_id; :id end

      def resource_name; "#{service_name}::#{name}" end

      def service_name; Ros::Sdk.configured_services[Settings.service.name] end
    end

    # rubocop:disable Metrics/BlockLength
    included do
      # urn:partition:service:region:account_id:resource_type/id
      def to_urn; "#{self.class.to_urn}/#{send(self.class.urn_id)}" end

      def current_tenant; self.class.current_tenant end

      after_commit :enqueue_after_commit_jobs

      after_commit :stream_cloud_event, if: -> { Settings.event_logging.enabled }

      def stream_cloud_event
        type = "#{Settings.service.name}.#{self.class.name.underscore}"
        Ros::StreamCloudEventJob.perform_later(type, id, cloud_event_data)
      end

      def enqueue_after_commit_jobs
        Ros::PlatformProducerEventJob.perform_now(self)
        # perform(self)
        # Ros::TenantProducerEventJob.perform_now(self)
      end

      def perform(record)
        data = { event: record.persisted?, data: record }.to_json
        queues = ['storage']
        queues.each do |queue|
          _queue_name = "#{queue}_platform_consumer_events".to_sym
          # Ros::PlatformConsumerEventJob.set(queue: queue_name).perform_later(data)
          perform_later(data)
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def perform_later(record)
        Rails.logger.debug record
        payload = JSON.parse(record)
        event = payload['event']
        data = payload['data']
        urn = Ros::Urn.from_urn(data['urn'])
        if urn.is_platform_urn?
          # PlatformEventProcessor.send(method, urn: urn, event: event, data: data)
          return
        end

        schema_name = Tenant.account_id_to_schema(urn.account_id)
        Rails.logger.debug("Schema name #{schema_name}")
        tenant = Tenant.find_by(schema_name: schema_name)
        # raise InvalidTenantError unless tenant
        tenant.switch do
          method = "#{urn.service_name}_#{urn.resource_type}"
          PlatformEventProcessor.send(method, urn: urn, event: event, data: data)
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def as_json(*)
        super.merge('urn' => to_urn)
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
    # rubocop:enable Metrics/BlockLength
  end
end
