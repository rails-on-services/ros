# frozen_string_literal: true

module Users
  class SessionsController < Iam::SessionsController
    protected

    def login_user!
      @current_user = User.find_by(username: sign_in_params[:username])
      return if current_user.nil?
      return unless current_user.confirmed?

      current_user&.valid_password? sign_in_params[:password]
    end

    def sign_in_params
      jsonapi_params.permit(%i[email username password account_id])
    end
  end
end
