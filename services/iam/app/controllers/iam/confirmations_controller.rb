# frozen_string_literal: true

module Iam
  class ConfirmationsController < Devise::ConfirmationsController
    include IsTenantScoped

    skip_before_action :authenticate_it!, only: %i[create show]

    respond_to :json

    # POST /resource/confirmation
    def create
      Apartment::Tenant.switch tenant_schema(reset_params) do
        return super unless find_user!

        @current_user.send_confirmation_instructions

        if successfully_sent?(@current_user)
          render status: :ok, json: json_resource(resource_class: user_resource, record: current_user)
        else
          render status: :bad_request
        end
      end
    end

    # GET /resource/confirmation
    def show
      mail_token = begin
                     Ros::Jwt.new(confirmation_params[:token]).decode
                   rescue JWT::DecodeError => e
                     render status: :bad_request, json: { errors: e }
                     return
                   end

      return unless mail_token

      Apartment::Tenant.switch tenant_schema(mail_token) do
        res = User.confirm_by_token(mail_token[:token])
        if res.confirmed?
          render status: :ok, json: json_resource(resource_class: user_resource, record: res)
        else
          render status: :bad_request, json: { errors: res.errors }
        end
      end
    end
  end
end