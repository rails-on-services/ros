# frozen_string_literal: true

module Ros
  class HealthzMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # Respond with 200 to Kubernetes health check
      return [200, { 'Content-Type' => 'text/plain' }, ['']] if env.fetch('PATH_INFO') == '/healthz'

      @app.call(env)
    end
  end
end
