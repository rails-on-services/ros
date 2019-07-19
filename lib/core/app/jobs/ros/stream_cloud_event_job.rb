# frozen_string_literal: true

module Ros
  # ApplicationRecordConcern after_commit enques this job
  # If any event listeners have been configured for this object+event combination then
  # enque a PlatformConsumerEventJob on the listening service's platform_consumer_events queue
  class StreamCloudEventJob < Ros::ApplicationJob
    queue_as "#{Settings.service.name}_stream_cloud_event"

    def perform(object)
      # TODO: add any gem dependencies to core_root/ros-core.gemspec
      # TODO: Configure the fluentd yaml in whistler_root/deployment.yml
      # TODO: update fluentd logger code in lib/ros/core/engine.rb to configure itself from deployment.yml 
      # NOTE: when you change any code in the engine file you need to restart rails
      # from the shell type 'src' which stop rails; rails console
      # if no need ot restart then from shell just type 'rc'
      # TODO: Play with it in the console
      # TODO: Implement code to convert object to cloud event hash format
      # TODO: serialize the data payload with avro_turf
      # binding.pry
      # data = { event: object.persisted?, data: object }.to_json
    end
  end
end
