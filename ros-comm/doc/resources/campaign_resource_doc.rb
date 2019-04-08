# frozen_string_literal: true

class CampaignResourceDoc < ApplicationDoc
  route_base 'campaigns'

  api :index, 'All Campaigns'
  api :show, 'Single Campaign'
  api :create, 'Create Campaign'
  api :update, 'Update Campaign'
end
