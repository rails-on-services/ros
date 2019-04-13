# frozen_string_literal: true

class Tenant < Cognito::ApplicationRecord
  include Ros::TenantConcern
end
