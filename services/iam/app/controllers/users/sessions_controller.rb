# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   binding.pry
  #   render json: {a: 'b'}
  #   # super
  # end

  # POST /resource/sign_in
  # def create
  #   user = User.find_by(email: params[:email])
  #   # binding.pry
  #   # render json: user
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   # binding.pry
  #   # devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  #   ActiveSupport::HashWithIndifferentAccess[email: 'test', password: 'test']
  # end
end
