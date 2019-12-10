# frozen_string_literal: true

class PoolPolicy < Cognito::ApplicationPolicy
  def show?
    IronHide.can? user, :read, record
  end

  def update?
    IronHide.can? user, :write, record
  end

  def index?
    IronHide.can? user, :list, record
  end
end
