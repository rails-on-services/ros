# frozen_string_literal: true

require 'aws-sdk-s3'
require_relative 'settings'

module Ros
  module Infra
    module Aws
      class Storage
        include Ros::Infra::Aws::Settings
        include Ros::Infra::Storage
        attr_accessor :config, :name, :client, :resource, :status, :notification_configuration

        def initialize(user_config)
          self.name = user_config.name
          self.config = user_config.to_hash.slice(:region)
          self.client = ::Aws::S3::Client.new(credentials.merge(config))
          self.status = :not_configured
          if user_config.notifications
            self.notification_configuration = { bucket: name, notification_configuration: user_config.notifications.to_hash }
          else
            self.notification_configuration = {}
          end

          # We rescue here, report errors and continue because the application
          # should still be able to run even without access to external storage or queue service
          begin
            client.head_bucket(bucket: name)
            self.status = :ok
            self.resource = ::Aws::S3::Resource.new(client: client).bucket(name)
            configure_notifications unless notification_configuration.empty?
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
            self.status = error.messge
            Rails.logger.warn("Unkown error creating/listing bucket #{name}. #{error}")
            # TODO: Send exception report to Sentry
          end
        end

        def configure_notifications
          client.put_bucket_notification_configuration(notification_configuration)
          Rails.logger.info("Notifications successufully configured notifications for #{name} with #{notification_configuration}")
        rescue ::Aws::S3::Errors::InvalidArgument => error
          Rails.logger.warn("Unable to create notification on bucket #{name}. #{error}")
          # TODO: Send exception report to Sentry
        rescue ::Aws::S3::Errors::NoSuchBucket => error
          Rails.logger.warn("Unable to create notification on bucket #{name}. #{error}")
          # TODO: Send exception report to Sentry
        rescue StandardError => error
          self.status = error.message
          Rails.logger.warn("Unkown error creating bucket notification on #{name}. #{error}")
          # TODO: Send exception report to Sentry
        end

        # Example: Ros::Infra.resources.storage.app.ls("csv")
        def ls(pattern = nil)
          unless status.eql?(:ok)
            Rails.logger.warn("Attempt list #{pattern} on bucket #{name} when status #{status}")
            return
          end
          # NOTE: This should be when using -l
          return client.list_objects(bucket: name).contents.map(&:key) unless pattern

          # NOTE: This is from regular ls
          # return client.list_objects(bucket: name).contents.each_with_object([]) { |ar, o| o.append(ar.key) }
          # binding.pry
          # resource.objects(prefix: path).select do |obj|
          resource.objects.select do |obj|
            # obj.key.match(/[.]gz$/)
            obj.key.match(/#{pattern}/)
          end
        end

        def rm(path)
          local = path.start_with?('fs:')
          path.gsub!(/^fs:/, '')
          if local
            FileUtils.rm("#{local_prefix}/#{path}")
          else
            client.delete_object(bucket: name, key: path)
          end
        end

        def head_object(path)
          client.head_object(bucket: name, key: path)
        end

        # Ros::Infra.resources.storage.app.cp(source, target)
        # by default source is 'storage' unless the prefix 'fs:' is part of the source name
        # cp('this/file.txt') # => Copies storage:this/file.txt to fs:file.txt
        # cp('this/file.txt', 'that/name') If 
        # cp('fs:this/file') # 
        # cp('fs:this/file', 'that/name')
        def cp(source, target = nil, metadata = {})
          storage = source.start_with?('fs:') ? :target : :source
          cmd = storage.eql?(:source) ? :get : :put
          source = source.gsub(/^fs:/, '')
          target ||= File.basename(source)
          exec(cmd, source, target, metadata)
        end

        def exec(cmd, source, target, metadata = {})
          unless status.eql?(:ok)
            Rails.logger.warn("#{cmd} #{source} on bucket #{name} not attempted due to status #{status}")
            return
          end

          if cmd.eql?(:get)
            resource.object(source).get(response_target: "#{local_prefix}/#{target}")
          elsif cmd.eql?(:put)
            resource.object(target).upload_file("#{local_prefix}/#{source}", metadata: metadata)
          end
        rescue ::Aws::S3::Errors::InvalidAccessKeyId
          self.status = error.code
          Rails.logger.warn('Invalid credentials')
          # TODO: Send exception report to Sentry
        rescue StandardError => error
          Rails.logger.warn("#{cmd} #{source} on bucket #{name} failed with error #{error.message}")
          # TODO: Send exception report to Sentry
        end

        def local_prefix; "#{Rails.root}/tmp/fs" end
=begin
        def get(source, target)
          unless status.eql?(:ok)
            Rails.logger.warn("Failed attempt to get #{source} from bucket #{name} with status #{status}")
            return
          end
          # local_path = File.dirname(source)
          # FileUtils.mkdir_p(local_path) unless Dir.exist?(local_path)
          resource.object(source).get(response_target: target)
        rescue StandardError => error
          Rails.logger.warn("Failed attempt to get #{source} from bucket #{name} with error #{error.message}")
          # TODO: Send exception report to Sentry
        end

        def put(source, target)
          unless status.eql?(:ok)
            Rails.logger.warn("Failed attempt to put #{source} to bucket #{name} when status #{status}")
            return
          end
          resource.object(target).upload_file(source)
        rescue ::Aws::S3::Errors::InvalidAccessKeyId
          self.status = error.code
          Rails.logger.warn('Invalid credentials')
          # TODO: Send exception report to Sentry
        rescue StandardError => error
          Rails.logger.warn("Failed attempt to put #{source} to bucket #{name} with error #{error.message}")
          # TODO: Send exception report to Sentry
        end
=end
      end
    end
  end
end
