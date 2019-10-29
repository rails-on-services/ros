# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Users::PasswordsController < Iam::PasswordsController
  protected

  def password_params
    jsonapi_params.permit(%i[email username password password_confirmation account_id])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
