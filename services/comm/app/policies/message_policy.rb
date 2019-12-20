# frozen_string_literal: true

class MessagePolicy < Comm::ApplicationPolicy
  def create?
    can_create = super
    return can_create unless can_create

    user.cognito_user_id.nil?
  end
end
