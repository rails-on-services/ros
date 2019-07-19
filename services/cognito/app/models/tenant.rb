# frozen_string_literal: true

class Tenant < Cognito::ApplicationRecord
  include Ros::TenantConcern

  def login_attribute
    platform_properties.symbolize_keys[:login_attribute_key]
  end
end
