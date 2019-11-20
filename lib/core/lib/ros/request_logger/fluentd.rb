# frozen_string_literal: true

require 'rack/fluentd_logger'

module Ros
  module RequestLogger
    class Fluentd < Rack::FluentdLogger
      def self.params_from_env(data)
        env = data[:env]
        # NOTE: some objects inside :env are dropped by Rack::FluentdLogger so
        # create request.body from rails action_dispatch
        {
          request_body: env['action_dispatch.request.request_parameters']&.to_json,
          request_method: env['REQUEST_METHOD'],
          request_headers: request_headers(data),
          # NOTE: some case "/" to be %2F.
          request_path: env['PATH_INFO']&.gsub('%2F', '/'),
          request_query_string: env['QUERY_STRING'],
          request_host: env['HTTP_HOST'] || env['SERVER_NAME'],
          request_remote_addr: env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'],
          response_headers: response_headers(data),
          meta: metadata(data)
        }
      end

      def self.metadata(data)
        {
          tenant: data[:env]['X-AccountId'],
          cognito_user_id: data[:env]['X-CognitoUserId'],
          iam_user_id: data[:env]['X-IAMUserId']
        }
      end

      def self.request_headers(data)
        request_headers = Hash[*data[:env].select { |k, _v| k.to_s.start_with? 'HTTP_' }
                                          .reject { |k, _v| k.to_s.in? %w[HTTP_HOST HTTP_VERSION] }
                                          .collect { |k, v| [k.to_s.sub(/^HTTP_/, ''), v] }
                                          .collect { |k, v| [k.to_s.split('_').collect(&:capitalize).join('-'), v] }
                                          .flatten]

        request_headers.stringify_keys.inject([]) do |pairs, (k, v)|
          pairs << { "key" => k , "value" => v }
        end
      end

      def self.response_headers(data)
        data[:headers].stringify_keys.inject([]) do |pairs, (k, v)|
          pairs << { "key" => k , "value" => v }
        end
      end

      def self.preprocessor
        lambda { |data|
          # NOTE: param data is a hash with keys
          # :env, :timestamp, :response_time, :code, :body and :headers
          # We are filtering the env data and formatting the remaining params
          hash = {}
          hash[:request_time] = data[:timestamp].iso8601
          hash[:latency] = data[:response_time] * 1000
          hash[:response_status_code] = data[:code]
          hash[:response_body] = data[:body].join.slice(0..65_534)
          hash.merge!(params_from_env(data))
          hash.as_json
        }
      end
    end
  end
end
