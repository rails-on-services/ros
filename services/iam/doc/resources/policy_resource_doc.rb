# frozen_string_literal: true

class PolicyResourceDoc < ApplicationDoc
  route_base 'policies'

  api :index, 'All Policys'
  api :show, 'Single Policy'
  api :create, 'Create Policy'
  api :update, 'Update Policy'
end
