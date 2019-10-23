# frozen_string_literal: true

class PublicKeyResourceDoc < ApplicationDoc
  route_base 'public_keys'

  api :index, 'All Public_keys'
  api :show, 'Single Public_key'
  api :create, 'Create Public_key'
  api :update, 'Update Public_key'
end
