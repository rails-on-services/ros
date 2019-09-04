# frozen_string_literal: true

class Tenant < Organization::ApplicationRecord
  include Ros::TenantConcern
end
