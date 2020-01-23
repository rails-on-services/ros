# frozen_string_literal: true

class TenantPolicy < Ros::ApplicationPolicy
  def create?
    user.root?
  end
end
