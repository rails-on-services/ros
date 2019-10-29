# frozen_string_literal: true

module Users
  class PasswordsController < Iam::PasswordsController
    protected

    def password_params
      jsonapi_params.permit(%i[email username password password_confirmation account_id])
    end
  end
end
