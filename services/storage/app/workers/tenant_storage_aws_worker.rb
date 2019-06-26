# frozen_string_literal: true

# require 'shoryuken'
# require 'aws-sdk-sqs'

# TODO: Configure S3 to put a message on the queue when a file is uploaded to the storage S3 bucket
# TODO: Add jj
class SqsEventJob < Ros::ApplicationJob
# class StorageEventJob < Ros::ApplicationJob
  # queue_as "#{Settings.service.name}_platform_consumer_events"
  # require_relative '../../spec/dummy/config/application'
  # Rails.application.initialize!
  include Shoryuken::Worker

  # NOTE: This is the same queue name as in Redis; There is no conflict b/c the SQS is independent of Redis
  shoryuken_options queue: "#{Settings.service.name}_platform_consumer_events", auto_delete: true

  # TODO: Create a Ros::LifecycleEvent that knows how to serialize and deserialize itself
  # then move this code there
  def perform(sqs_msg, payload)
    # event = Ros::LifecycleEvent.new(payload)
    # event.urn; event.tenant
    payload = JSON.parse(payload)
    urn = Ros::Urn.from_urn(payload['data']['urn'])
    schema_name = Tenant.account_id_to_schema(urn.account_id)
    Tenant.find_by(schema_name: schema_name).switch do
      method = "#{urn.service_name}_#{urn.resource_type}"
      puts "send(method, urn: urn, event: payload['event'], data: payload['data'])"
    end
  end
end
