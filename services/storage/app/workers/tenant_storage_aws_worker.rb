# frozen_string_literal: true

# The AWS specific implementation to handle new files added to an S3 bucket

require_relative '../../spec/dummy/config/application'
Rails.application.initialize!
# sqs_client = Rails.configuration.x.infra.resources.mq.primary.client
# Rails.configuration.x.infra.services.storage.enable_notifications(sqs_client)

class TenantStorageAwsWorker < TenantStorageWorker
  include Shoryuken::Worker
  # binding.pry

  shoryuken_options queue: Rails.configuration.x.infra.resources.storage.primary.notifications['storage/sftp/home'],
                    auto_delete: true

  # Process a lifecycle event from the S3 bucket
  def perform(_sqs_msg, payload)
    # binding.pry
    return unless (records = JSON.parse(payload)['Records'])

    records.each do |record|
      event = TenantStorageAwsEvent.from_record(record)
      process_event(event) if event.type && event.name
    end
  end
end

# NOTE: The event is the interface that each provider must implement
TenantStorageAwsEvent = Struct.new(:event_time, :event_name, :bucket, :key, :etag, :size) do
  def self.from_record(record)
    new(record['eventTime'], record['eventName'], record['s3']['bucket']['name'], record['s3']['object']['key'],
        record['s3']['object']['eTag'], record['s3']['object']['size'])
  end

  def schema_name
    return unless (match_result = key.match(/\d{9}/))

    match_result[0].scan(/\d{3}/).join('_')
  end

  def type; key.split('/')[4]&.singularize end

  def name; key.split('/')[5..-1]&.join('/') end
end

# {"eventVersion"=>"2.0",
#  "eventSource"=>"aws:s3",
#  "awsRegion"=>"us-east-1",
#  "eventTime"=>"2019-06-09T13:51:10.944237Z",
#  "eventName"=>"ObjectCreated:Put",
#  "userIdentity"=>{"principalId"=>"AIDAJDPLRKLG7UEXAMPLE"},
#  "requestParameters"=>{"sourceIPAddress"=>"127.0.0.1"},
#  "responseElements"=>{"x-amz-request-id"=>"f386daea", "x-amz-id-2"=>"eftixk72aD6Ap51TnqcoF8eFidJG9Z/2"},
#  "s3"=>
#   {"s3SchemaVersion"=>"1.0",
#    "configurationId"=>"testConfigRule",
#    "bucket"=>{"name"=>"sftp", "ownerIdentity"=>{"principalId"=>"A3NL1KOZZKExample"}, "arn"=>"arn:aws:s3:::sftp"},
#    "object"=>
#     {"key"=>"home/foo/uploads/README.md",
#      "size"=>1024,
#      "eTag"=>"d41d8cd98f00b204e9800998ecf8427e",
#      "versionId"=>nil,
#      "sequencer"=>"0055AED6DCD90281E5"}}}
