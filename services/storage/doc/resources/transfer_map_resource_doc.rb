# frozen_string_literal: true

class TransferMapResourceDoc < ApplicationDoc
  route_base 'transfer_maps'

  api :index, 'All Transfer Maps'
  api :show, 'Single Transfer Map'
  api :create, 'Create Transfer Map'
  api :update, 'Update Transfer Map'
end
