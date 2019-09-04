# frozen_string_literal: true

module Ros
  module Sdk
    # TODO: This should probably be setting the JWT which has the relevant info
    # TODO: Is RequestStore a requirement?
    class Middleware < Faraday::Middleware
      def call(env)
        # env[:request_headers]['X-PERX-CLIENT'] = 'Internal'
        # re = /(\/internal\/api_v1\/(\w*)_tenants(\w*))/
        # unless env[:url].path.match(re)
        #   RequestStore.store[:tenant_request].try(:as_headers).try(:each) do |key, value|
        #     env[:request_headers][key] = value.to_s unless value.nil?
        #   end
        # end
        # env[:request_headers]['If-Modified-Since'] = RequestStore.store[:if_modified] if RequestStore.store[:if_modified]
        # # env[:request_headers]['X-Request-Id'] = RequestStore.store[:request_id]
        # #      env[:request_headers]['X-Request-Id'] = Thread.current[:request_id] # NOTE: Not present when calling Tenant.create from rails console
        env.request_headers['Authorization'] = Ros::Sdk::Credential.authorization # if Ros::Sdk.authorization
        env.request_headers.merge!(Ros::Sdk::Credential.request_headers)
        # env.request_headers['Authorization'] = RequestStore.store['Authorization']
        response = @app.call(env)
        # binding.pry
        Ros::Sdk::Credential.authorization = response.env.response_headers['authorization'] if response.env.response_headers['authorization']
        # RequestStore.store['Authorization'] = env.request_headers['Authorization']
        response
      end
    end
  end
end
