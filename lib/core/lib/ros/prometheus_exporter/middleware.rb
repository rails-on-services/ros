# frozen_string_literal: true

require 'prometheus_exporter/middleware'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module Ros
  module PrometheusExporter
    class Middleware < ::PrometheusExporter::Middleware
      def call(env)
        queue_time = measure_queue_time(env)

        MethodProfiler.start
        result = @app.call(env)
        info = MethodProfiler.stop

        result
      ensure
        status = (result && result[0]) || -1
        params = env['action_dispatch.request.parameters']
        action, controller = nil
        if params
          action = params['action']
          controller = params['controller']
        end

        @client.send_json(
          type: 'ros_web_collector',
          timings: info,
          queue_time: queue_time,
          action: action,
          controller: controller,
          status: status,
          # tenant is set by tenant_middleware
          tenant: env['X-AccountId'] || ''
        )
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
