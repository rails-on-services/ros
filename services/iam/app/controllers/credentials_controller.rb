# frozen_string_literal: true

class CredentialsController < Iam::ApplicationController
  # TODO: Remove this once we support registration of callbacks
  def blackcomb
    res = BlackcombUserCreate.call(params: blackcomb_params)
    if res.success?
      @current_jwt = Ros::Jwt.new(res.model.jwt_payload)
      render json: json_resource(resource_class: UserResource, record: res.model), status: :created
    else
      resource = ApplicationResource.new(res, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  private

  def blackcomb_params
    permitted_params = jsonapi_params.permit(:account_id)

    HashWithIndifferentAccess.new({ current_user: context[:user] }.merge(permitted_params))
  end
end
