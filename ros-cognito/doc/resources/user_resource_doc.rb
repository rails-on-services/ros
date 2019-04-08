# frozen_string_literal: true

class UserResourceDoc < ApplicationDoc
  route_base 'users'

  api :index, 'All Users'
  api :show, 'Single User'
  api :create, 'Create User'
  api :update, 'Update User'
end
