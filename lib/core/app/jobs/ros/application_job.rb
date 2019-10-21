# frozen_string_literal: true

module Ros
  class ApplicationJob < ActiveJob::Base
    # Automatically retry jobs that encountered a deadlock
    # retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    # discard_on ActiveJob::DeserializationError

    before_perform do
      schema_name = Apartment::Tenant.current
      tenant = Tenant.find_by(schema_name: schema_name)
      tenant.set_role_credential
    end
  end
end
