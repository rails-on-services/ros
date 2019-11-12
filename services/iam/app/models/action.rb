# frozen_string_literal: true

class Action < Iam::ApplicationRecord
  after_commit :update_policy_actions

  def update_policy_actions
    User.all.each(&:recalculate_attached_actions)
  end
end

# class ReadAction < Action; end
