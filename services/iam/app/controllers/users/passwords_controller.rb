# frozen_string_literal: true

module Users
  class PasswordsController < Iam::PasswordsController
    protected

    def find_user!
      @current_user = User.find_by(username: password_params[:username])
    end

    def password_params
      jsonapi_params.permit(%i[email username password password_confirmation account_id])
    end

    # NOTE: the received token should be the encoded token we sent on the email
    # for password reset. JWT token should have the accountId, username and
    # Devise's reset token. Since the FE does not have the encryption key,
    # if they tamper the token with other params this would fail on validating
    # when we try to use it. Also this generated JWT is not valid for auth
    # as it doesnt have any credentials attached.
    def reset_params
      jsonapi_params.permit(%i[token password password_confirmation])
    end
  end
end
