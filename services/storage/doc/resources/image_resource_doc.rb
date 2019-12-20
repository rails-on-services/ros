# frozen_string_literal: true

class ImageResourceDoc < ApplicationDoc
  route_base 'images'

  api :index, 'All Images'
  api :show, 'Single Image'
  api :create, 'Create Image'
end
