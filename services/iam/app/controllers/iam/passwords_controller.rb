# frozen_string_literal: true

module Iam
  class PasswordsController < Devise::PasswordsController
    include IsTenantScoped

    skip_before_action :authenticate_it!, only: %i[create update]

    respond_to :json

    # POST /resource/password
    def create
      binding.pry

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
      mail_token = begin
                     Ros::Jwt.new(reset_params[:token]).decode
                   rescue JWT::DecodeError => e
                     render status: :bad_request, json: { errors: e }
                     return
                   end

      return unless mail_token

      Apartment::Tenant.switch tenant_schema(mail_token) do
        decoded_params = {
          reset_password_token: mail_token[:token],
          password: reset_params[:password],
          password_confirmation: reset_params[:password_confirmation]
        }

        res = User.reset_password_by_token(decoded_params)

        if res.persisted?
          render status: :ok, json: json_resource(resource_class: user_resource, record: res)
        else
          render status: :bad_request, json: { errors: res.errors }
        end
      end
    end
  end
end
