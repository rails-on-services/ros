# frozen_string_literal: true

class ColumnMapResourceDoc < ApplicationDoc
  route_base 'column_maps'

  api :index, 'All Column_maps'
  api :show, 'Single Column_map'
  api :create, 'Create Column_map'
  api :update, 'Update Column_map'
end
