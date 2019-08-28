      # frozen_string_literal: true

      class OrgResourceDoc < ApplicationDoc
        route_base 'orgs'

        api :index, 'All Orgs'
        api :show, 'Single Org'
        api :create, 'Create Org'
        api :update, 'Update Org'
      end
