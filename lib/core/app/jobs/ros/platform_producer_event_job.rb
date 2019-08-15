# frozen_string_literal: true

module Ros
  # ApplicationRecordConcern after_commit enques this job
  # If any event listeners have been configured for this object+event combination then
  # enque a PlatformConsumerEventJob on the listening service's platform_consumer_events queue
  class PlatformProducerEventJob < Ros::ApplicationJob
    queue_as "#{Settings.service.name}_platform_producer_events"

    def perform(object)
      # binding.pry
      data = { event: object.persisted?, data: object }.to_json
      queues = ['storage']
      queues.each do |queue|
        queue_name = "#{queue}_platform_consumer_events".to_sym
        Ros::PlatformConsumerEventJob.set(queue: queue_name).perform_later(data)
      end

      # return unless queues = Settings.queues&.lifecycle&.models.try(:[], self.class.name.underscore)
      # queues.each do |queue|
      #   # TODO: refactor client, queue_name and  queue_url
      #   queue_name = "#{queue}_lifecycle"
      #   queue_url = "http://localstack:4576/queue/#{queue_name}"
      #   Rails.configuration.x.client.send_message(queue_url: queue_url, message_body: { destroyed: destroyed?, data: self }.to_json)
      # end
    end
  end
end

    # event = Ros::LifecycleEvent.new(payload)
    # event.urn; event.tenant
    # binding.pry
    # payload = JSON.parse(payload)
    # urn = Ros::Urn.from_urn(payload['data']['urn'])
    # schema_name = Tenant.account_id_to_schema(urn.account_id)
    # Tenant.find_by(schema_name: schema_name).switch do
    #   method = "#{urn.service_name}_#{urn.resource_type}"
    #   puts "send(method, urn: urn, event: payload['event'], data: payload['data'])"
    # end

