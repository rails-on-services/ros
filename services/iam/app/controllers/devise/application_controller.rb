# frozen_string_literal: true

class Devise::ApplicationController < Devise::SessionsController
  skip_before_action :authenticate_it!, on: :create

  respond_to :json

  # POST /resource/sign_in
  def create
    Apartment::Tenant.switch tenant do
      return super unless login_user!

      render json: json_resource(user_resource, current_user)
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
    return Apartment::Tenant.current unless sign_in_params[:tenant_id]

    Tenant.find_by(id: sign_in_params[:tenant_id])&.schema_name || Apartment::Tenant.current
  end

  # @TODO Move both methods to own module/core for non resourceable actions
  def json_resource(klass, record, context = nil)
    resource = klass.new(record, context)
    serialize_resource(klass, resource)
  end

  def serialize_resource(klass, resource)
    JSONAPI::ResourceSerializer.new(klass).serialize_to_hash(resource)
  end
end