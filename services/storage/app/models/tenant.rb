# frozen_string_literal: true

class Tenant < Storage::ApplicationRecord
  include Ros::TenantConcern
end
