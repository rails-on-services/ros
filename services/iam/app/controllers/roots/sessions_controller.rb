# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Roots::SessionsController < Iam::SessionsController
  protected

  def login_user!
    @current_user = Root.find_by(email: sign_in_params[:email])
    current_user&.valid_password? sign_in_params[:password]
  end

  def sign_in_params
    jsonapi_params.permit(%i[email password])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
