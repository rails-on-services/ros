# frozen_string_literal: true

class BranchResourceDoc < ApplicationDoc
  route_base 'branches'

  api :index, 'All Branches'
  api :show, 'Single Branch'
  api :create, 'Create Branch'
  api :update, 'Update Branch'
end
