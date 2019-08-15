# frozen_string_literal: true

class UploadResourceDoc < ApplicationDoc
  route_base 'uploads'

  api :index, 'All Uploads'
  api :show, 'Single Upload'
  api :create, 'Create Upload'
  api :update, 'Update Upload'
end
