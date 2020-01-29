# frozen_string_literal: true

module Ros
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
            render status: :ok, json: { message: 'ok' }
          else
            render status: :bad_request
          end
        end
      end

      # Devise v4.7.1 expects this to be a GET request and not PUT which is
      # definitely not what I expected.
      # https://github.com/plataformatec/devise/blob/v4.7.1/app/controllers/devise/confirmations_controller.rb#L21
      #
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
            render status: :ok, json: { message: 'ok' }
          else
            render status: :bad_request, json: { errors: res.errors }
          end
        end
      end
    end
  end
end
