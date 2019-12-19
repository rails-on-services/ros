# frozen_string_literal: true

class UsersController < Iam::ApplicationController
  def create
    res = UserCreate.call(params: create_params)
    if res.success?
      render json: json_resource(resource_class: UserResource, record: res.model), status: :created
    else
      resource = ApplicationResource.new(res, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  def create_params
    jsonapi_params.merge(relationships: params.require(:data).fetch(:relationships, {})).permit!
  end
end
