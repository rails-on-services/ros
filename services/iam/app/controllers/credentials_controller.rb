# frozen_string_literal: true

class CredentialsController < Iam::ApplicationController
  before_action :validate_platform_owner, only: [:blackcomb]

  # TODO: Remove this once we support registration of callbacks
  def blackcomb
    tenant = Tenant.find_by_schema_or_alias(blackcomb_params[:account_id])
    credential = tenant.root.credentials.create
    if credential.persisted?
      render json: json_resource(resource_class: CredentialResource, record: credential), status: :created
    else
      resource = CredentialResource.new(credential, nil)
      handle_exception JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  private

  def validate_platform_owner
    return true if Apartment::Tenant.current == 'public' && context[:user].root?

    render json: { errors: ['Invalid credentials'] }, status: :forbidden
  end

  def blackcomb_params
    jsonapi_params.permit(:account_id)
  end
end
