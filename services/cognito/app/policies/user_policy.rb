# frozen_string_literal: true

class UserPolicy < Cognito::ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.cognito_user_id
        scope.where(id: user.cognito_user_id)
      else
        scope.all
      end
    end
  end
end
