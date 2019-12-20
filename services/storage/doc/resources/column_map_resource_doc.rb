# frozen_string_literal: true

class ColumnMapResourceDoc < ApplicationDoc
  route_base 'column_maps'

  api :index, 'All Column Maps'
  api :show, 'Single Column Map'
  api :create, 'Create Column Map'
  api :update, 'Update Column Map'
end
