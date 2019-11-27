# frozen_string_literal: true

module Iam
  class PasswordsController < Devise::PasswordsController
    include IsTenantScoped

    skip_before_action :authenticate_it!, only: :create

    respond_to :json

    # POST /resource/password
    def create
      Apartment::Tenant.switch tenant_schema(password_params) do
        return super unless find_user!

        @current_user.send_reset_password_instructions

        if successfully_sent?(@current_user)
          render status: :ok, json: json_resource(resource_class: user_resource, record: current_user)
        else
          render status: :bad_request
        end
      end
    end

    # PUT /resource/password
    def update
      Apartment::Tenant.switch tenant_schema(password_params) do
        if current_user.password_update!(password_params)
          render status: :ok, json: json_resource(resource_class: user_resource, record: current_user)
        else
          render status: :bad_request
        end
      end
    end
  end
end
