# frozen_string_literal: true

module Ros
  module Iam
    class SessionsController < Devise::SessionsController
      include IsTenantScoped

      skip_before_action :authenticate_it!, only: :create

      respond_to :json

      # POST /resource/sign_in
      def create
        Apartment::Tenant.switch tenant_schema(sign_in_params) do
          return super unless login_user!

          @current_jwt = Ros::Jwt.new(current_user.jwt_payload)
          render json: json_resource(resource_class: user_resource, record: current_user)
        end
      end
    end
  end
end
