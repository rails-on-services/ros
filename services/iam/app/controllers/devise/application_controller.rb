# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Devise::ApplicationController < Devise::SessionsController
  skip_before_action :authenticate_it!, on: :create

  respond_to :json

  # POST /resource/sign_in
  def create
    Apartment::Tenant.switch tenant do
      return super unless login_user!

      @current_jwt = Ros::Jwt.new(current_user.jwt_payload)
      render json: json_resource(resource_class: user_resource, record: current_user)
    end
  end

  protected

  def login_user!
    false
  end

  def user_resource
    "#{resource_name.capitalize}Resource".constantize
  end

  def tenant
    return Tenant.schema_name_from(account_id: sign_in_params[:account_id]) if sign_in_params[:account_id].present?
    return Tenant.find_by(alias: sign_in_params[:alias])&.schema_name if sign_in_params[:alias].present?

    Apartment::Tenant.current
  end
end
# rubocop:enable Style/ClassAndModuleChildren
