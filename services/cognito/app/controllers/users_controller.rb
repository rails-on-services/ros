# frozen_string_literal: true

class UsersController < Cognito::ApplicationController
  # TODO: Should this be in a separate controller nested under users?
  def merge
    res = UsersMerge.call(params: merge_params, id: params[:id], current_user: current_user)
    if res.success?
      render json: json_resource(resource_class: TransactionResource, record: res.model)
    else
      resource = ApplicationResource.new(res, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  private

  def merge_params
    params.permit_all!
  end
end
