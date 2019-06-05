# frozen_string_literal: true

module Ros
  module RequestLogger
    class Fluentd
      def self.preprocessor
        lambda { |data|
          # param data is a hash with keys :env, :timestamp, :response_time, :code, :body and :headers

          hash = { 'request' => {}, 'response' => {}, 'meta' => {} }

          response_body = data[:body].join.slice(0..65534)

          request_header = Hash[*data[:env].select{ |k, v| k.to_s.start_with? 'HTTP_' }
            .reject{ |k, v| k.to_s.in? %w(HTTP_HOST HTTP_VERSION) } # host is already in request.host
            .collect { |k, v| [k.to_s.sub(/^HTTP_/, ''), v] }
            .collect { |k, v| [k.to_s.split('_').collect(&:capitalize).join('-'), v] }
            .flatten]

          # some objects inside :env is dropped by Rack::FluentdLogger, so create request.body from rails action_dispatch
          hash['request']['body']         = data[:env]["action_dispatch.request.request_parameters"]&.to_json
          hash['request']['method']       = data[:env]['REQUEST_METHOD']
          hash['request']['path']         = data[:env]['PATH_INFO']&.gsub('%2F', '/') # some case "/" to be %2F.
          hash['request']['query_string'] = data[:env]['QUERY_STRING']
          hash['request']['host']         = data[:env]['HTTP_HOST'] || data[:env]['SERVER_NAME']
          hash['request']['time']         = data[:timestamp].iso8601
          hash['request']['header']       = request_header
          hash['request']['remote_addr']  = data[:env]['HTTP_X_FORWARDED_FOR'] || data[:env]['REMOTE_ADDR'] || nil
          hash['response']['status_code'] = data[:code]
          hash['response']['header']      = data[:headers]
          hash['response']['body']        = response_body
          # TODO: Get the tenant from basic auth or JWT's URN
          # hash['meta']['tenant']          = data[:env]['tenant']
          hash['latency']                 = data[:response_time] * 1000

          hash
        }
      end
    end
  end
end
