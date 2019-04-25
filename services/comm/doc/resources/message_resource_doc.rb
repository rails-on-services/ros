# frozen_string_literal: true

class MessageResourceDoc < ApplicationDoc
  route_base 'messages'

  api :index, 'All Messages'
  api :show, 'Single Message'
  api :create, 'Create Message'
  api :update, 'Update Message'
end
