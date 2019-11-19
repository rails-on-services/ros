# frozen_string_literal: true

module Ros
  class TenantLogger
    def initialize app
      @app = app
    end

    def call(env)
      logger = ActiveSupport::TaggedLogging.new(Rails.logger)
      logger.tagged Apartment::Tenant.current do
        @app.call(env)
      end
    end
  end
end
