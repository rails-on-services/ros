# frozen_string_literal: true

class ReportResourceDoc < ApplicationDoc
  route_base 'reports'

  api :index, 'All Reports'
  api :show, 'Single Report'
end
