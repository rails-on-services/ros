# frozen_string_literal: true

class TenantsDoc < ApplicationDoc
  route_base '/tenants'

  api :index, 'GET list of tenants' do
    query! :schema_name, String
    resp 200, 'success', :json, data: { name: 'test' }
  end
end
