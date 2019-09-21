# frozen_string_literal: true

require 'prometheus_exporter/server'

module Ros
  module PrometheusExporter
    class WebCollector < ::PrometheusExporter::Server::WebCollector
      def type; 'ros_web_collector' end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def observe(obj)
        default_labels = {
          controller: obj['controller'] || 'other',
          action: obj['action'] || 'other',
          tenant: obj['tenant'] || 'other'
        }
        custom_labels = obj['custom_labels']
        labels = custom_labels.nil? ? default_labels : default_labels.merge(custom_labels)

        @http_requests_total.observe(1, labels.merge(status: obj['status']))

        if (timings = obj['timings'])
          @http_duration_seconds.observe(timings['total_duration'], labels)
          if (redis = timings['redis'])
            @http_redis_duration_seconds.observe(redis['duration'], labels)
          end
          if (sql = timings['sql'])
            @http_sql_duration_seconds.observe(sql['duration'], labels)
          end
        end
        return unless (queue_time = obj['queue_time'])

        @http_queue_duration_seconds.observe(queue_time, labels)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
