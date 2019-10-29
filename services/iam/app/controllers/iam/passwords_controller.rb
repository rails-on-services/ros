# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Iam::PasswordsController < Devise::PasswordsController
  include IsTenantScoped

  respond_to :json

  # PUT /resource/password
  def update
    Apartment::Tenant.switch tenant_schema do
      if current_user.password_update!(password_params)
        render status: :ok, json: json_resource(resource_class: user_resource, record: current_user)
      else
        render status: :bad_request
      end
    end
  end

  def tenant
    Tenant.find_by(schema_name: Tenant.account_id_to_schema(password_params[:account_id])) ||
      Tenant.find_by(alias: password_params[:account_id])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
