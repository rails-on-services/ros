# frozen_string_literal: true

class RolePolicyJoin < Iam::ApplicationRecord
  belongs_to :role
  belongs_to :policy

  after_commit :update_policy_actions, on: %i[create destroy]

  def update_policy_actions
    user.recalculate_attached_actions
  end
end
