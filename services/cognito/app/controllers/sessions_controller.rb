# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  skip_before_action :authenticate_it!, on: :create

  respond_to :json

  # POST /resource/sign_in
  def create
    return super unless login_user!
    render json: json_resource(UserResource, resource)
  end

  protected

  def login_user!
    self.resource = User.by_login_attribute(sign_in_params[:login_attribute_value])
    # Devise#confirmable
    return unless resource.active_for_authentication?

    resource.valid_password? sign_in_params[:password]
  end

  def sign_in_params
    params.require(:data).require(:attributes).permit(%i[login_attribute_value password])
  end

  private

  # @TODO move to own module
  def json_resource(klass, record, context = nil)
    resource = klass.new(record, context)
    serialize_resource(klass, resource)
  end

  def serialize_resource(klass, resource)
    JSONAPI::ResourceSerializer.new(klass).serialize_to_hash(resource)
  end

end