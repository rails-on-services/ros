# frozen_string_literal: true

class Roots::SessionsController < Devise::ApplicationController

  protected

  def login_user!
    @current_user = Root.find_by(email: sign_in_params[:email])
    current_user&.valid_password? sign_in_params[:password]
  end

  def sign_in_params
    params.require(:data).require(:attributes).permit(%i[email password])
  end

end
