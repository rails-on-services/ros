# frozen_string_literal: true

class PoolResourceDoc < ApplicationDoc
  route_base 'pools'

  api :index, 'All Pools'
  api :show, 'Single Pool'
  api :create, 'Create Pool'
  api :update, 'Update Pool'
end
