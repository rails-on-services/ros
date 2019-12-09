# frozen_string_literal: true

class MessagesController < Comm::ApplicationController
  before_action :check_user, only: :create

  def create
    res = MessageCreate.call(params: assign_params)
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

  def check_user
    if context[:user].cognito_user_id
      render(status: :forbidden,
             json: { errors: [{ status: '403', code: :forbidden, title: 'Forbidden' }] })
    end
  end
end
