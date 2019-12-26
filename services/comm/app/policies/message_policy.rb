# frozen_string_literal: true

class MessagePolicy < Comm::ApplicationPolicy
  def create?
    return false if user.cognito_user_id

    super
  end
end
