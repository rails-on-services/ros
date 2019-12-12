# frozen_string_literal: true

class PoolsController < Cognito::ApplicationController
  def create
    res = PoolCreate.call(params: create_params, user: context[:user])
    if res.success?
      render json: json_resource(resource_class: PoolResource, record: res.model, context: context), status: :created
    else
      resource = ApplicationResource.new(res, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  private

  def create_params
    # TODO: Think of the proper pattern for this
    creatable_fields = PoolResource.creatable_fields(context) + [:base_pool_id, { segments: {} }]
    jsonapi_params.permit(creatable_fields)
  end
end
