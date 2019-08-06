# frozen_string_literal: true

class TransferMapResourceDoc < ApplicationDoc
  route_base 'transfer_maps'

  api :index, 'All Transfer_maps'
  api :show, 'Single Transfer_map'
  api :create, 'Create Transfer_map'
  api :update, 'Update Transfer_map'
end
