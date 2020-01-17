# frozen_string_literal: true

# def scheduler.on_pre_trigger(job, _trigger_time)
#   puts "PRE triggering job #{job.id}"
# end

# def scheduler.on_post_trigger(job, _trigger_time)
#   puts "POST triggered job #{job.id}"
# end

# scheduler.every '30s' do
#   STDOUT.puts "stdout printed at #{Time.zone.now}"
# end

# scheduler.every '60s' do
#   Rails.logger.debug "debug printed at #{Time.zone.now}"
# end

module Ros
  module Scheduler
    class TenantHandler
      attr_reader :count, :job_class, :queue

      def initialize(job_class:, queue_name: nil)
        @count = 0
        @job_class = job_class
        @queue = Sidekiq::Queue.new(queue_name || job_class.queue_name)
      end

      # Handles invocations from Scheduler
      def call(_job, _time)
        @count += 1
        Rails.logger.debug ". #{self.class} called at #{Time.current} (#{count})"
        per_tenant { |tenant| perform_later(tenant) }
      end

      # NOTE: Override in subclass to implement a custom block
      def perform_later(tenant)
        job_class.perform_later(params: { account_id: tenant.account_id })
      end

      def per_tenant
        ActiveRecord::Base.connection_pool.with_connection do
          Tenant.find_each do |tenant|
            next if job_enqueued(tenant)

            sleep(1)
            tenant.switch do
              Rails.logger.debug "Running job on #{tenant.account_id} (#{count})"
              yield tenant
            end
          end
        end
      end

      def job_enqueued(tenant)
        queue.select do |worker_job|
          args = worker_job.item['args'].first
          params = args['arguments'].first['params']
          args['job_class'] == job_class.name && params['account_id'] == tenant.account_id
        end.size.positive?
      end
    end
  end
end
