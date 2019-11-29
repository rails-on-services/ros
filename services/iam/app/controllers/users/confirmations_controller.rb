# frozen_string_literal: true

module Users
  class ConfirmationsController < Iam::ConfirmationsController
    protected

    def find_user!
      @current_user = User.find_by(username: confirmation_params[:username])
    end

    def confirmation_params
      jsonapi_params.permit(%i[email username account_id])
    end
  end
end
