# frozen_string_literal: true

class ReportResourceDoc < ApplicationDoc
  route_base 'reports'

  api :index, 'All Reports'
  api :show, 'Single Report'
  api :create, 'Create Report'
  api :update, 'Update Report'
end
