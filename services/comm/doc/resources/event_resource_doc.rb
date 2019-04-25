# frozen_string_literal: true

class EventResourceDoc < ApplicationDoc
  route_base 'events'

  api :index, 'All Events'
  api :show, 'Single Event'
  api :create, 'Create Event'
  api :update, 'Update Event'
end
