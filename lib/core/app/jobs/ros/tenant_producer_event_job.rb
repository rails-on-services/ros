# frozen_string_literal: true

module Ros
  class TenantProducerEventJob < Ros::ApplicationJob
    queue_as "#{Settings.service.name}_tenant_producer_events"

    def perform(object)
      _data = { event: object.persisted?, data: object }.to_json
      # Have any notifications been configured for this object+event combination?
      # If no then return, otherwise execute the notification
      # This will be a read of the database table 'tenant_notifications'
      # and then execute an http(s) POST to the configured endpoint
    end
  end
end
