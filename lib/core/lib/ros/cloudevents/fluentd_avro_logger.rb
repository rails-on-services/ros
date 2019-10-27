# frozen_string_literal: true

require 'base64'
require 'logger'
require 'msgpack'
require 'faraday'
require 'fluent-logger'
require 'avro_turf/messaging'

module Ros
  module CloudEvents
    class Event
      ATTRS = %i[id source specversion type datacontentencoding datacontenttype schemaurl subject time data].freeze
      attr_accessor(*ATTRS)

      def to_h
        ATTRS.each_with_object({}) { |i, h| h[i] = send(i) }
      end
    end

    # A fluentd logger send reocrds using fluentd's HTTP input protocol
    class FluentHttpLogger < Fluent::Logger::LoggerBase
      def initialize(tag_prefix = nil, options = {})
        super()

        @tag_prefix = tag_prefix
        @host = options[:host] || 'localhost'
        @port = options[:port] || 9880

        @msgpack_factory = MessagePack::Factory.new
        @logger = options[:logger]
        @debug = options[:debug]
      end

      def post_with_time(tag, map, time)
        record = @msgpack_factory.dump(map)
        tag = "#{@tag_prefix}.#{tag}" if @tag_prefix
        connection.post("/#{tag}", _body = record) { |req|
          req.params['time'] = time.to_f
        }
      end

      private

      def logger
        return @logger if @logger

        @logger = ::Logger.new(STDERR)
        @logger.level = if @debug
                          ::Logger::DEBUG
                        else
                          ::Logger::INFO
                        end
        @logger
      end

      def connection
        @connection ||= Faraday.new(
          "http://#{@host}:#{@port}",
          headers: { 'Content-Type' => 'application/msgpack' },
          request: {
            open_timeout: 2,   # opening a connection
            timeout: 5         # waiting for response
          }
        )
      end
    end

    class FluentdAvroLogger
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize

      attr_accessor :avro

      # source: source field for event, also used as tag of fluentd record
      # options: hash of configurations
      def initialize(source, options)
        @source = source
        @host = options[:host]
        @port = options[:port]
        @schema_registry_url = options[:schema_registry_url]
        @schemas_path = options[:schemas_path]
        @transport = (options[:transport] || 'http').downcase
        @logger = options[:logger] || ::Logger.new(STDOUT)
        @cloudevents_specversion = options[:cloudevents_specversion] || '0.4-wip'
        @tag_prefix = options[:name]

        fluentd_logger_options = {
          host: @host,
          port: @port,
          logger: @logger
        }

        @fluentd_logger = if @transport.eql?('http')
                            FluentHttpLogger.new(@tag_prefix, fluentd_logger_options)
                          else
                            Fluent::Logger::FluentLogger.new(@tag_prefix, fluentd_logger_options)
                          end

        @avro = AvroTurf::Messaging.new(registry_url: @schema_registry_url, schemas_path: @schemas_path)
      end

      def log_event(type, id, data, subject: nil, time: Time.now)
        event = Event.new
        event.source = @source
        event.specversion = @cloudevents_specversion
        event.type = type
        event.id = id.to_s
        event.subject = subject
        event.datacontenttype = 'application/avro'
        event.datacontentencoding = 'Base64'
        event.time = time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        event.data = Base64.encode64(@avro.encode(data, schema_name: type, subject: type + '-value'))
        @fluentd_logger.post_with_time(@source, event.to_h, time)
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end
  end
end
