# frozen_string_literal: true

module Ros
  module ApplicationRecordConcern
    extend ActiveSupport::Concern
    include ApiBelongsTo
  
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
    end


    included do
      # urn:partition:service:region:account_id:resource_type/id
      def to_urn; "#{self.class.to_urn}/#{send(self.class.urn_id)}" end

      def current_tenant; self.class.current_tenant end

      after_commit :enqueue_after_commit_jobs
      after_commit :stream_cloud_event  # , if: -> { Settings.workers.enabled }

      def stream_cloud_event
        Ros::StreamCloudEventJob.perform_now(self)
      end

      def enqueue_after_commit_jobs
        Ros::PlatformProducerEventJob.perform_now(self)
        # Ros::TenantProducerEventJob.perform_now(self)
      end

      def as_json(*)
        super.merge({ 'urn' => to_urn })
      end
    end
  end
end
