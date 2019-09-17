# frozen_string_literal: true

module Ros
  class DtraceMiddleware
    DTRACE_HEADERS = %w[HTTP_X_REQUEST_ID HTTP_X_B3_TRACEID HTTP_X_B3_SPANID HTTP_X_B3_PARENTSPANID
                        HTTP_X_B3_SAMPLED HTTP_X_B3_FLAGS HTTP_X_OT_SPAN_CONTEXT].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      Ros::Sdk::Credential.request_headers = env.slice(*DTRACE_HEADERS)
      Ros::Sdk::Credential.request_headers.transform_keys! { |key| key[5..-1].downcase.tr('_', '-') }
      status, headers, response = @app.call(env)
      [status, headers, response]
    end
  end
end
