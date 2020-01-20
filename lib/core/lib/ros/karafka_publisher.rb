# frozen_string_literal: true

module Ros
  module KarafkaPublisher
    def defaults
      { schema_name: Apartment::Tenant.current }
    end

    def kafka_message(data = {})
      defaults.merge(data).to_json
    end

    def publish_to(topic, data = {})
      message = kafka_message(data)
      Rails.logger.log "[Karafka::Publisher][#{topic}]: #{message}"
      WaterDrop::SyncProducer.call(message, topic: topic)
      true
    end
  end
end
