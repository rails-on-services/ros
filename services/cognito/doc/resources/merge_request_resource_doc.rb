# frozen_string_literal: true

class MergeRequestResourceDoc < ApplicationDoc
  route_base 'merge_requests'

  api :index, 'All Merge_requests'
  api :show, 'Single Merge_request'
  api :create, 'Create Merge_request'
  api :update, 'Update Merge_request'
end
