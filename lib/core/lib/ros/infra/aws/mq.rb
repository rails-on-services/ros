# frozen_string_literal: true

require 'aws-sdk-sqs'
# require_relative 'settings'

module Ros
  module Infra
    module Aws
      class StorageMessage
        attr_accessor :records

        def initialize(message: nil, payload: nil)
          payload = message.messages.first.body if message
          payload ||= {}.to_json
          @records = JSON.parse(payload)['Records'] || []
        end

        def events
          records.each_with_object([]) do |record, ary|
            ary << StorageEvent.from_record(record)
          end
        end
      end

      # NOTE: The event is the interface that each provider must implement
      StorageEvent = Struct.new(:event_time, :event_name, :bucket, :key, :etag, :size) do
        def self.from_record(record)
          object = record['s3']['object']
          new(record['eventTime'], record['eventName'], record['s3']['bucket']['name'], object['key'],
              object['eTag'], object['size'])
        end

        def schema_name
          return unless (match_result = key.match(/\d{9}/))

          match_result[0].scan(/\d{3}/).join('_')
        end

        def type; event_name.eql?('ObjectCreated:Put') ? 'created' : 'unknown' end
      end

      # An instance of this class represents a single Queue
      class Mq
        include Ros::Infra::Mq
        attr_accessor :config, :name, :client, :resource, :status, :attrbutes, :bucket_name

        def initialize(resource_config, client_config)
          # binding.pry
          self.name = resource_config.name
          # self.config = config.to_hash.slice(:region)
          self.status = :not_configured
          self.bucket_name = resource_config.bucket_name

          begin
            # binding.pry
            self.client = ::Aws::SQS::Client.new(client_config)
            self.resource = client.create_queue(queue_name: name, attributes: create_attributes)
            client.set_queue_attributes(queue_url: resource.queue_url, attributes: policy_attributes)
            attributes # set's the member variable
            self.status = :ok
          rescue ::Aws::Errors::MissingRegionError => error
            self.status = error.message
            Rails.logger.warn(error.message)
          rescue ::Aws::SQS::Errors::InvalidClientTokenId
            Rails.logger.warn('Invalid credentials')
            # TODO: Send exception report to Sentry
          rescue StandardError => error
            # binding.pry
            self.status = error.message
            Rails.logger.warn("Unkown error creating queue #{name}. #{status}")
            # TODO: Send exception report to Sentry
          end
        end

        def get; client.receive_message(queue_url: resource.queue_url) end
        def put(message); client.send_message(queue_url: resource.queue_url, message_body: message) end
        def purge; client.purge_queue(queue_url: resource.queue_url) end

        def attributes
          @attributes ||= create_attributes.merge(policy_attributes)
        end

        def create_attributes
          name.end_with?('.fifo') ? { 'FifoQueue' => 'true', 'ContentBasedDeduplication' => 'true' } : {}
        end

        def policy_attributes
          { 'Policy' => policy.to_json }
        end

        def policy
          { Version: "2008-10-17",
            Id: "#{arn}/SQSDefaultPolicy",
            Statement: [{
              Sid: "__default_statement_ID",
              Effect: "Allow",
              Principal: {
                AWS: "*"
              },
              Action: ["SQS:SendMessage"],
              Resource: arn,
              Condition: {
                ArnLike: { "AWS:SourceArn": bucket_arn }
              }
            }]
          }
        end

        # TODO: Get bucket name from an ENV
        def bucket_arn; "arn:aws:s3:*:*:#{bucket_name}" end

        def arn; "arn:aws:sqs:#{region}:#{account_id}:#{name}" end
        def region; URI(resource.queue_url).hostname.split('.')[1] end
        def account_id; URI(resource.queue_url).path.split('/')[1] end
      end
    end
  end
end
