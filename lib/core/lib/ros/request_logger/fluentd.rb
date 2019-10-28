# frozen_string_literal: true

module Ros
  module RequestLogger
    class Fluentd
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.preprocessor
        lambda { |data|
          # param data is a hash with keys :env, :timestamp, :response_time, :code, :body and :headers
          hash = {}
          response_body = data[:body].join.slice(0..65_534)

          # host is already in request.host so reject it
          request_headers = Hash[*data[:env].select { |k, _v| k.to_s.start_with? 'HTTP_' }
                                           .reject { |k, _v| k.to_s.in? %w[HTTP_HOST HTTP_VERSION] }
                                           .collect { |k, v| [k.to_s.sub(/^HTTP_/, ''), v] }
                                           .collect { |k, v| [k.to_s.split('_').collect(&:capitalize).join('-'), v] }
                                           .flatten]

          request_headers = request_headers.stringify_keys.inject([]) do |pairs, (k, v)| pairs << { "key" => k , "value" => v } end
          response_headers = data[:headers].stringify_keys.inject([]) do |pairs, (k, v)| pairs << { "key" => k , "value" => v } end

          # some objects inside :env is dropped by Rack::FluentdLogger so create request.body from rails action_dispatch
          hash['request_body']         = data[:env]['action_dispatch.request.request_parameters']&.to_json
          hash['request_method']       = data[:env]['REQUEST_METHOD']
          hash['request_path']         = data[:env]['PATH_INFO']&.gsub('%2F', '/') # some case "/" to be %2F.
          hash['request_query_string'] = data[:env]['QUERY_STRING']
          hash['request_host']         = data[:env]['HTTP_HOST'] || data[:env]['SERVER_NAME']
          hash['request_time']         = data[:timestamp].iso8601
          hash['request_headers']      = request_headers
          hash['request_remote_addr']  = data[:env]['HTTP_X_FORWARDED_FOR'] || data[:env]['REMOTE_ADDR'] || nil
          hash['response_status_code'] = data[:code]
          hash['response_headers']     = response_headers
          hash['response_body']        = response_body
          # TODO: Get the tenant from basic auth or JWT's URN
          # hash['meta']['tenant']          = data[:env]['tenant']
          hash['latency']              = data[:response_time] * 1000

          hash
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
