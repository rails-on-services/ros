# frozen_string_literal: true

module Ros
  class ApplicationJob < ActiveJob::Base
    # Automatically retry jobs that encountered a deadlock
    # retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    # discard_on ActiveJob::DeserializationError

    def self.execute(job_data)
      Apartment::Tenant.switch(job_data['tenant']) do
        super
      end
    end

    def serialize
      super.merge('tenant' => Apartment::Tenant.current)
    end
  end
end
