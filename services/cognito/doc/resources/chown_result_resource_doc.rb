# frozen_string_literal: true

class ChownResultResourceDoc < ApplicationDoc
  route_base 'chown_results'

  api :index, 'All Chown_results'
  api :show, 'Single Chown_result'
  api :create, 'Create Chown_result'
  api :update, 'Update Chown_result'
end
