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

      class Mq
        include Ros::Infra::Aws
        include Ros::Infra::Mq

        def initialize(client_config, config)
          # binding.pry
          require 'shoryuken'
          self.client = ::Aws::SQS::Client.new(credentials.merge(client_config))
          Shoryuken.configure_server { |config| config.sqs_client = client }
        end
      end

      class Storage
        include Ros::Infra::Aws
        include Ros::Infra::Storage
        attr_accessor :name, :notifications

        def initialize(client_config, config)
          require 'aws-sdk-s3'
          self.client = ::Aws::S3::Client.new(credentials.merge(client_config))
          self.name = config.bucket_name
          self.notifications = {}

          begin
            client.head_bucket(bucket: config.bucket_name)
          rescue ::Aws::S3::Errors::NotFound
            client.create_bucket(bucket: config.bucket_name)
          rescue ::Aws::S3::Errors::Http502Error
            # swallow
          end
        end

        def enable_notifications(sqs, notifications_path)
          # queue_name = "#{notifications_path.gsub('/', '-')}-events"
          queue_name = notifications_path.gsub('/', '-')
          notifications[notifications_path] = queue_name
          attrs = queue_name.end_with?('.fifo') ? { 'FifoQueue' => 'true', 'ContentBasedDeduplication' => 'true' } : {}
          # binding.pry
          sqs.client.create_queue({ queue_name: queue_name, attributes: attrs })
          client.put_bucket_notification_configuration(
            bucket: name, notification_configuration: notification_configuration(queue_name, notifications_path)
          )
        end

        # def queue_name; "#{name}-events" end

        def notification_configuration(queue_name, notifications_path)
          {
            queue_configurations: [{
              queue_arn: "arn:aws:sqs:#{credentials['region']}:#{values['account_id']}:#{queue_name}",
              events: ["s3:ObjectCreated:#{notifications_path}/*"]
            }]
          }
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
          resource.objects().select do |obj|
            # obj.key.match(/[.]gz$/)
            obj.key.match(/#{pattern}/)
          end
        end

        def get(path)
          local_path = "#{Rails.root}/tmp/#{File.dirname(path)}"
          FileUtils.mkdir_p(local_path) unless Dir.exists?(local_path)
          resource.object(path).get(response_target: "#{local_path}/#{File.basename(path)}")
        end

        def put(path, local_path = "#{Rails.root}/tmp/#{path}")
          resource.object(path).upload_file(local_path)
        end
      end
    end
  end
end
