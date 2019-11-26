# frozen_string_literal: true

class MetabaseCardResourceDoc < ApplicationDoc
  route_base 'metabase_cards'

  api :index, 'All Metabase_cards'
  api :show, 'Single Metabase_card'
  api :create, 'Create Metabase_card'
  api :update, 'Update Metabase_card'
end
