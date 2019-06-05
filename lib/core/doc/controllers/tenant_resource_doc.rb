# frozen_string_literal: true

class TenantResourceDoc < ApplicationDoc
  route_base 'tenants'
  # doc_tag name: 'ExampleTagName', description: "ExamplesController's APIs"

  api :index, 'All Tenants'
  api :show, 'Single Tenant'
  api :create, 'Create Tenant'
  api :update, 'Update Tenant'
end
