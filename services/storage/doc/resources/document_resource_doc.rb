# frozen_string_literal: true

class DocumentResourceDoc < ApplicationDoc
  route_base 'documents'

  api :index, 'All Documents'
  api :show, 'Single Document'
  api :create, 'Create Document'
  api :update, 'Update Document'
end
