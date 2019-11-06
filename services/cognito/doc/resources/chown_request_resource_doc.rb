# frozen_string_literal: true

class ChownRequestResourceDoc < ApplicationDoc
  route_base 'chown_requests'

  api :index, 'All Chown requests'
  api :show, 'Single Chown request'
  api :create, 'Create Chown request'
  api :update, 'Update Chown request'
end
