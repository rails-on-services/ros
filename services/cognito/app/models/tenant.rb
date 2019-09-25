# frozen_string_literal: true

class Tenant < Cognito::ApplicationRecord
  include Ros::TenantConcern

  def login_attribute
    settings[:login_attribute_key]
  end

  def requires_user_confirmation?
    settings[:email_confirmation]
  end

  private

  def settings
    platform_properties.symbolize_keys
  end
end
