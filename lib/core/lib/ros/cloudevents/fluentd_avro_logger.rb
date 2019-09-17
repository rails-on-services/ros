# frozen_string_literal: true

require 'base64'
require 'fluent-logger'
require 'avro_turf/messaging'

module Ros
  module CloudEvents
    class Event
      ATTRS = [
        :id,
        :source,
        :specversion,
        :type,
        :datacontentencoding,
        :datacontenttype,
        :schemaurl,
        :subject,
        :time,
        :data
      ]
      attr_accessor(*ATTRS)

      def to_h
        ATTRS.each_with_object({}) { |i, h| h[i] = send(i) }
      end
    end

    class FluentdAvroLogger
      class << self
        attr_reader :logger, :cloudevents_specversion, :avro

        def configure(name: nil, host: nil, port: 24_224, schema_registry_url: nil, schemas_path: nil,
                      cloudevents_specversion: '0.4-wip')
          @avro = AvroTurf::Messaging.new(registry_url: schema_registry_url, schemas_path: schemas_path)
          @cloudevents_specversion = cloudevents_specversion
          @logger = Fluent::Logger::FluentLogger.new(name, host: host, port: port)
        end
      end

      def initialize(source)
        @source = source
      end

      def log_event(type, id, data, subject: nil, time: Time.zone.now)
        event = Event.new
        event.source = @source
        event.specversion = self.class.cloudevents_specversion
        event.type = type
        event.id = id
        event.subject = subject
        event.datacontenttype = 'application/avro'
        event.datacontentencoding = 'Base64'
        event.time = time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        # binding.pry
        event.data = Base64.encode64(self.class.avro.encode(data, schema_name: type, subject: type + '-value'))
        # binding.pry
        self.class.logger.post(@source, event.to_h)
      end
    end
  end
end
