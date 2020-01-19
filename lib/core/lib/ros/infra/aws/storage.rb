# frozen_string_literal: true

require 'aws-sdk-s3'
# require_relative 'settings'

module Ros
  module Infra
    module Aws
      # rubocop:disable Metrics/ClassLength
      class Storage
        include Ros::Infra::Storage
        attr_accessor :name, :client, :resource, :status, :notification_configuration

        def initialize(resource_config, client_config)
          @name = resource_config.name
          @status = :not_configured
          @notification_configuration = {}
          if resource_config.notifications
            @notification_configuration = { bucket: name, notification_configuration: resource_config.notifications.to_hash }
          end

          # Rescue from and report errors then continue so that the application
          # will continue to run even without access to this resource
          begin
            self.client = ::Aws::S3::Client.new(client_config)
            client.head_bucket(bucket: name)
            self.status = :ok
            self.resource = ::Aws::S3::Resource.new(client: client).bucket(name)
            configure_notifications unless notification_configuration.empty?
          rescue ::Aws::Errors::MissingRegionError => error
            self.status = error.message
            Rails.logger.warn(error.message)
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
          rescue ::Aws::S3::Errors::NotFound
            if client_config[:region].eql? 'localstack'
              client.create_bucket(bucket: name)
              retry
            else
              self.status = error.code
              Rails.logger.warn("Unable to create bucket #{name}")
            end
          # rescue ::Aws::S3::Errors::InvalidBucketName => error
          #   self.status = error.code
          #   Rails.logger.warn("Unable to create bucket #{name}")
          rescue StandardError => error
            self.status = error.message
            Rails.logger.warn("Unkown error creating/listing bucket '#{name}'\nError: #{error}")
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

        def get_object(path)
          client.get_object(bucket: name, key: path)
        end

        def presigned_url(path)
          ::Aws::S3::Presigner.new(client: client).presigned_url(:get_object, bucket: name, key: path)
        end

        # Ros::Infra.resources.storage.app.cp(source, target)
        # by default source is 'storage' unless the prefix 'fs:' is part of the source name
        # cp('this/file.txt') # => Copies storage:this/file.txt to fs:file.txt
        # cp('this/file.txt', 'that/name') If
        # cp('fs:this/file') #
        # cp('fs:this/file', 'that/name')
        def cp(source, target = nil, metadata = {})
          src = source.start_with?('fs:')
          dest = target.start_with?('fs:')
          return unless src_service ^ dest_service

          # service_name = src.index(':') ? src.split(':')[0] : dest.split(':')[0]
          # response.add(exec: "docker cp #{src} #{dest}".gsub("#{service_name}:", "#{service_id(service_name)}:"))

          storage = src ? :target : :source
          cmd = src ? :get : :put
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

        def local_prefix
          prefix = "#{Rails.root}/tmp/fs"
          Dir.mkdir_p(prefix) unless Dir.exist? prefix
          prefix
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
