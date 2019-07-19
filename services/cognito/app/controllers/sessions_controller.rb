# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  skip_before_action :authenticate_it!, on: :create

  respond_to :json

  # POST /resource/sign_in
  def create
    Apartment::Tenant.switch tenant do
      super unless login_user!
      render json: json_resource(UserResource, current_user)
    end
  end

  protected

  def login_user!
    return false unless sign_in_params[:login_attribute_key].in? User.column_names
    @current_user = User.find_by(sign_in_params[:login_attribute_key] => sign_in_params[:login_attribute_value])
    @current_user&.valid_password? sign_in_params[:password]
  end

  def sign_in_params
    params.require(:data).require(:attributes).permit(%i[login_attribute_key login_attribute_value password tenant_id])
  end

  def json_resource(klass, record, context = nil)
    resource = klass.new(record, context)
    serialize_resource(klass, resource)
  end

  def serialize_resource(klass, resource)
    JSONAPI::ResourceSerializer.new(klass).serialize_to_hash(resource)
  end

  #######
  def tenant
    return Apartment::Tenant.current unless sign_in_params[:tenant_id]

    Tenant.find_by(id: sign_in_params[:tenant_id])&.schema_name || Apartment::Tenant.current
  end

end