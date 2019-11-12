# frozen_string_literal: true

class Action < Iam::ApplicationRecord
  after_commit :update_policy_actions

  def update_policy_actions
    User.find_each(&:recalculate_attached_actions)
  end
end
