# frozen_string_literal: true

require_relative '../../../spec/dummy/config/application'
Rails.application.initialize!

module Aws
  class StorageWorker
    include Shoryuken::Worker

    shoryuken_options queue: Ros::Infra.resources.mq.storage_data.name, auto_delete: true
    Rails.logger.debug("Configured to receive events from queue: #{Ros::Infra.resources.mq.storage_data.name}")

    # Process a lifecycle event from the S3 bucket
    def perform(_sqs_msg, payload)
      message = Ros::Infra::Aws::StorageMessage.new(payload: payload)
      Document.attach_from_storage_events(message.events)
    end
  end
end
