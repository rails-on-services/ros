# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Users::SessionsController < Iam::SessionsController
  protected

  def login_user!
    @current_user = User.find_by(username: sign_in_params[:username])
    current_user&.valid_password? sign_in_params[:password]
  end

  def sign_in_params
    jsonapi_params.permit(%i[email username password account_id])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
