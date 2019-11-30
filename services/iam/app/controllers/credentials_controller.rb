# frozen_string_literal: true

class CredentialsController < Iam::ApplicationController
  def index
    # NOTE: For us to identify the tenant schema in the tenant_middleware,
    # while using a Basic Token it triggers a remote call to the credentials
    # index trying to filter the credentials using the access_key. The
    # credentials for the root are currently stored in the public schema,
    # therefore we need to switch the context to public schema so we can
    # identify the root user.
    if context[:user].root?
      Apartment::Tenant.switch 'public' do
        return super
      end
    end

    super
  end
end
