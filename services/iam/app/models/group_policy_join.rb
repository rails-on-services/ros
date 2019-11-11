# frozen_string_literal: true

class GroupPolicyJoin < Iam::ApplicationRecord
  belongs_to :group
  belongs_to :policy

  after_commit :update_policy_actions, on: %i[create destroy]

  def update_policy_actions
    # user.recalculate_attached_actions
  end
end
