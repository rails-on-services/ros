# frozen_string_literal: true

class Tenant < Comm::ApplicationRecord
  include Ros::TenantConcern

  belongs_to :provider, optional: true

  store_accessor :platform_properties, :platform_twilio_enabled, :platform_aws_enabled
end
