# frozen_string_literal: true

class RootCredential < Credential
  def current_tenant
    Tenant.find(tenant_id)
  end
end
