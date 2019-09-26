# frozen_string_literal: true

class TenantPolicy < Iam::ApplicationPolicy
  include Ros::TenantPolicyConcern
end
