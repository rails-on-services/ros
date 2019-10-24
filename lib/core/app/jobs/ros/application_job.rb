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
      # Apartment::Tenant.switch!('222_222_222')
      schema_name = Apartment::Tenant.current
      next unless (@tenant = Tenant.find_by(schema_name: schema_name))

      @tenant.set_role_credential
    end

    def perform(*params)
      OperationResult.new(*operation_class.call(params))
    end

    def operation_class(_params)
      self.class.name.gsub('Job', '').constantize
    end
  end
end
