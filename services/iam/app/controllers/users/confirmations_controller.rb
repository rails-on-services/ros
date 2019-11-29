# frozen_string_literal: true

module Users
  class ConfirmationsController < Iam::ConfirmationsController
    protected

    def find_user!
      @current_user = User.find_by(username: reset_params[:username])
    end

    def reset_params
      jsonapi_params.permit %i[username email account_id]
    end

    # refer to Users::PasswordController.reset_params for details on why we
    # just allow :token
    def confirmation_params
      jsonapi_params.permit %i[token]
    end
  end
end
