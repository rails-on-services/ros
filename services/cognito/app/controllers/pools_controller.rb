# frozen_string_literal: true

class PoolsController < Cognito::ApplicationController
  def create
    return super unless params.key?(:base_pool_id) && params.key?(:segments)

    res = SegmentedPoolCreate.call(params: create_params, base_pool_id: params[:base_pool_id], segments: params[:segments])
    if res.success?
      render json: json_resource(resource_class: PoolResource, record: res.model), status: :created
    else
      resource = ApplicationResource.new(res, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  private

  def create_params
    jsonapi_params.permit(PoolResource.creatable_fields(context))
  end
end
