# frozen_string_literal: true

module Ros
  class ApplicationJob < ActiveJob::Base
    # Automatically retry jobs that encountered a deadlock
    # retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    # discard_on ActiveJob::DeserializationError

    queue_as "#{Settings.service.name}_default"

    attr_accessor :tenant

    before_perform do
      schema_name = Apartment::Tenant.current
      next unless (@tenant = Tenant.find_by(schema_name: schema_name))

      @tenant.set_role_credential
    end
  end
end
