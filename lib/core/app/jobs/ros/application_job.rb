# frozen_string_literal: true

# NOTE:
# Automatically retry jobs that encountered a deadlock:
#   retry_on ActiveRecord::Deadlocked
# Most jobs are safe to ignore if the underlying records are no longer available:
#   discard_on ActiveJob::DeserializationError

module Ros
  class ApplicationJob < ActiveJob::Base
    attr_accessor :tenant

    queue_as "#{Settings.service.name}_default"

    before_perform do
      schema_name = Apartment::Tenant.current
      next unless (@tenant = Tenant.find_by(schema_name: schema_name))

      @tenant.set_role_credential
      # TODO: Fix this. Use tenant's settings instead of static zone
      Time.zone = 'Asia/Singapore'
    end

    def perform(*params)
      operation_class.call(params)
    end

    def operation_class
      job_name = self.class.name.gsub('Job', '')
      job_name.constantize
    end
  end
end
