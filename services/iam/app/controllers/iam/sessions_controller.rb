# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Iam::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_it!, on: :create

  respond_to :json

  # POST /resource/sign_in
  def create
    Apartment::Tenant.switch tenant_schema do
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

  def tenant_schema
    tenant&.schema_name || Apartment::Tenant.current
  end

  def tenant
    Tenant.find_by(schema_name: Tenant.account_id_to_schema(sign_in_params[:account_id])) ||
      Tenant.find_by(alias: sign_in_params[:account_id])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
