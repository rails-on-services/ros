# frozen_string_literal: true

class MessagesController < Comm::ApplicationController
  def create
    res = MessageCreate.call(params: assign_params, user: context[:user])
    if res.success?
      render json: json_resource(resource_class: MessageResource, record: res.model), status: :created
    else
      resource = ApplicationResource.new(res, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  private

  def assign_params
    jsonapi_params.permit(MessageResource.creatable_fields(context))
  end
end
