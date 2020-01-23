# frozen_string_literal: true

class RootPolicy < Iam::ApplicationPolicy
  def create?
    user.root?
  end
end
