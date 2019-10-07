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
        attr_accessor :name, :attrs, :status

        def initialize(client_config, config)
          require 'aws-sdk-sqs'
          self.client = ::Aws::SQS::Client.new(credentials.merge(client_config))
          self.name = config.queue_name
          self.attrs = name&.end_with?('.fifo') ? { 'FifoQueue' => 'true', 'ContentBasedDeduplication' => 'true' } : {}

          begin
            client.create_queue(queue_name: name, attributes: attrs) if name
            self.status = :ok
          rescue ::Aws::SQS::Errors::InvalidClientTokenId
            Rails.logger.warn('Configured for SQS but no valid credentials')
            # TODO: Send exception report to Sentry
          rescue StandardError => error
            self.status = error.code
            Rails.logger.warn("Unkown error creating queue #{name}. #{error}")
            # TODO: Send exception report to Sentry
          end
        end

        def queues; client.list_queues end
      end

      class Storage
        include Ros::Infra::Aws
        include Ros::Infra::Storage
        attr_accessor :name, :notification_configuration, :status

        def initialize(client_config, config)
          require 'aws-sdk-s3'
          self.client = ::Aws::S3::Client.new(credentials.merge(client_config))
          self.name = config.bucket_name
          self.notification_configuration = {}
          self.status = :not_configured

          # We rescue here, report errors and continue because the application
          # should still be able to run even without access to external storage or queue service
          begin
            client.head_bucket(bucket: name)
            self.status = :ok
          rescue ::Aws::S3::Errors::Forbidden => error
            self.status = error.code
            Rails.logger.warn('Configured for S3 but no valid credentials')
            # TODO: Send exception report to Sentry
          rescue ::Aws::S3::Errors::Http301Error => error
            self.status = error.code
            Rails.logger.warn("S3 bucket not found in configured region #{error.context.config.region}")
          rescue ::Aws::S3::Errors::Http502Error => error
            self.status = error.code
            Rails.logger.warn("Unable to create bucket #{name}")
            # TODO: Send exception report to Sentry
          # TODO: On not found if the option to create has been passed then this should be good
          # rescue ::Aws::S3::Errors::NotFound
          #   begin
          #     client.create_bucket(bucket: name)
          #     self.status = :ok
          #   rescue ::Aws::S3::Errors::InvalidBucketName => error
          #     # TODO: Get the excpetion type and report it to Sentry
          #     self.status = error.code
          #     Rails.logger.warn("Unable to create bucket #{name}")
          #     # TODO: Send exception report to Sentry
          #   end
          rescue StandardError => error
            self.status = error.code
            Rails.logger.warn("Unkown error creating/listing bucket #{name}. #{error}")
            # TODO: Send exception report to Sentry
          end
        end

        def enable_notifications
          client.put_bucket_notification_configuration(notification_config)
          Rails.logger.info("Notifications successufully configured #{notification_config}")
        rescue ::Aws::S3::Errors::InvalidArgument => error
          Rails.logger.warn("Unable to create notification on bucket #{name}. #{error}")
          # TODO: Send exception report to Sentry
        rescue ::Aws::S3::Errors::NoSuchBucket => error
          Rails.logger.warn("Unable to create notification on bucket #{name}. #{error}")
          # TODO: Send exception report to Sentry
        rescue StandardError => error
          self.status = error.code
          Rails.logger.warn("Unkown error creating bucket notification on #{name}. #{error}")
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
          unless status.eql?(:ok)
            Rails.logger.warn("Attempt list #{pattern} on bucket #{name} when status #{status}")
            return
          end
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
          unless status.eql?(:ok)
            Rails.logger.warn("Attempt get #{path} on bucket #{name} when status #{status}")
            return
          end
          local_path = "#{Rails.root}/tmp/#{File.dirname(path)}"
          FileUtils.mkdir_p(local_path) unless Dir.exist?(local_path)
          resource.object(path).get(response_target: "#{local_path}/#{File.basename(path)}")
        rescue StandardError => error
          self.status = error.code
          Rails.logger.warn("Unkown error getting object #{path} from bucket #{name}. #{error}")
          # TODO: Send exception report to Sentry
        end

        def put(path, local_path = "#{Rails.root}/tmp/#{path}")
          unless status.eql?(:ok)
            Rails.logger.warn("Attempt put #{path} on bucket #{name} when status #{status}")
            return
          end
          resource.object(path).upload_file(local_path)
        rescue ::Aws::S3::Errors::InvalidAccessKeyId
          Rails.logger.warn('Configured for S3 but no valid credentials')
          # TODO: Send exception report to Sentry
        rescue StandardError => error
          self.status = error.code
          Rails.logger.warn("Unkown error putting object #{local_path} to bucket #{name}. #{error}")
          # TODO: Send exception report to Sentry
        end
      end
    end
  end
end
