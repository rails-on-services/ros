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
    end

    def perform(*params)
      operation_class(params).call(params)
    end

    def operation_class(params)
      return JSON.parse(params)['operation'].constantize if json?(params)

      job_name = self.class.name.gsub('Job', '')
      return "#{Settings.service.name}::Chown".underscore.classify.constantize if job_name == 'Chown'

      job_name.constantize
    end

    private

    def json?(params)
      JSON.parse(params).is_a?(Hash)
    rescue StandardError
      false
    end
  end
end
