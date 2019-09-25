# frozen_string_literal: true

require 'ros/infra'

module Ros
  module Infra
    module Aws
      extend ActiveSupport::Concern

      included do
        attr_accessor :client
      end

      def credentials
        {
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          region: ENV['AWS_DEFAULT_REGION']
        }
      end

      def values
        {
          account_id: ENV['AWS_ACCOUNT_ID']
        }
      end

      # An instance of this class represents a single Queue
      class Mq
        include Ros::Infra::Aws
        include Ros::Infra::Mq
        attr_accessor :name, :attrs

        def initialize(client_config, config)
          require 'aws-sdk-sqs'
          self.client = ::Aws::SQS::Client.new(credentials.merge(client_config))
          self.name = config.queue_name
          self.attrs = name&.end_with?('.fifo') ? { 'FifoQueue' => 'true', 'ContentBasedDeduplication' => 'true' } : {}

          begin
            client.create_queue(queue_name: name, attributes: attrs) if name
          rescue ::Aws::SQS::Errors::InvalidClientTokenId
            Rails.logger.warn('Configured for SQS but no valid credentials')
            # TODO: Send exception report to Sentry
          end
        end

        def queues; client.list_queues end
      end

      class Storage
        include Ros::Infra::Aws
        include Ros::Infra::Storage
        attr_accessor :name, :notification_configuration

        def initialize(client_config, config)
          require 'aws-sdk-s3'
          self.client = ::Aws::S3::Client.new(credentials.merge(client_config))
          self.name = config.bucket_name
          self.notification_configuration = {}

          # We rescue here, report errors and continue because the application
          # should still be able to run even without access to external storage or queue service
          begin
            client.head_bucket(bucket: name)
          rescue ::Aws::S3::Errors::Forbidden => e
            Rails.logger.warn('Configured for S3 but no valid credentials')
            # TODO: Send exception report to Sentry
          rescue ::Aws::S3::Errors::NotFound
            begin
              client.create_bucket(bucket: name)
            rescue ::Aws::S3::Errors::InvalidBucketName
              # TODO: Get the excpetion type and report it to Sentry
              Rails.logger.warn("Unable to create bucket #{name}")
              # TODO: Send exception report to Sentry
            end
          # rubocop:disable Lint/HandleExceptions
          rescue ::Aws::S3::Errors::Http502Error
            Rails.logger.warn("Unable to create bucket #{name}")
            # TODO: Send exception report to Sentry
            # rubocop:enable Lint/HandleExceptions
            # swallow
          end
        end

        def enable_notifications
          client.put_bucket_notification_configuration(notification_config)
          Rails.logger.info("Notifications successufully configured #{notification_config}")
        rescue ::Aws::S3::Errors::InvalidArgument => e
          Rails.logger.warn("Unable to create notification on bucket #{name}")
          # TODO: Send exception report to Sentry
        rescue ::Aws::S3::Errors::NoSuchBucket
          Rails.logger.warn("Unable to create notification on bucket #{name}")
          # TODO: Send exception report to Sentry
        end

        def notification_config; { bucket: name, notification_configuration: notification_configuration } end

        def add_queue_notification(queue_name:, events:, filter_rules:)
          notification_configuration[:queue_configurations] = [{
            # TODO: AWS account ID from configuration
            # queue_arn: "arn:aws:sqs:#{credentials['region']}:#{values['account_id']}:#{queue_name}",
		        queue_arn: "arn:aws:sqs:#{credentials[:region]}:251316246111:#{queue_name}",
            events: events,
            filter: { key: { filter_rules: filter_rules } }
          }]
        end

        def resource
          @resource ||= ::Aws::S3::Resource.new(client: client).bucket(name)
        end

        def ls(pattern = nil)
          # NOTE: This should be when using -l
          return client.list_objects(bucket: name) unless pattern

          # NOTE: This is from regular ls
          # return client.list_objects(bucket: name).contents.each_with_object([]) { |ar, o| o.append(ar.key) }
          # binding.pry
          # resource.objects(prefix: path).select do |obj|
          resource.objects.select do |obj|
            # obj.key.match(/[.]gz$/)
            obj.key.match(/#{pattern}/)
          end
        end

        def get(path)
          local_path = "#{Rails.root}/tmp/#{File.dirname(path)}"
          FileUtils.mkdir_p(local_path) unless Dir.exist?(local_path)
          resource.object(path).get(response_target: "#{local_path}/#{File.basename(path)}")
        end

        def put(path, local_path = "#{Rails.root}/tmp/#{path}")
          resource.object(path).upload_file(local_path)
        rescue ::Aws::S3::Errors::InvalidAccessKeyId
          Rails.logger.warn('Configured for S3 but no valid credentials')
          # TODO: Send exception report to Sentry
        end
      end
    end
  end
end
