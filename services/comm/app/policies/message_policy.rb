# frozen_string_literal: true

class MessagePolicy < Comm::ApplicationPolicy
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def create?
    user.cognito_user_id.nil?
  end
end
