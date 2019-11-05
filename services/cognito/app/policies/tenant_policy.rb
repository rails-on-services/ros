# frozen_string_literal: true

class TenantPolicy < Cognito::ApplicationPolicy
  include Ros::TenantPolicyConcern
end
