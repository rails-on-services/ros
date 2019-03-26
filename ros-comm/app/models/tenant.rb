# frozen_string_literal: true

class Tenant < Comm::ApplicationRecord
  include Ros::TenantConcern

  store_accessor :platform_properties, :platform_twilio_enabled
end
