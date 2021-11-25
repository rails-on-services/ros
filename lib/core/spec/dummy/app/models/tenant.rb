# frozen_string_literal: true

class Tenant < ::ApplicationRecord
  include Ros::TenantConcern
end
