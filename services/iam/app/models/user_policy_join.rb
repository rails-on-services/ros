# frozen_string_literal: true

class UserPolicyJoin < ApplicationRecord
  belongs_to :user
  belongs_to :policy

  after_commit :update_policy_actions, on: %i[create destroy]

  def update_policy_actions
    user.recalculate_attached_actions
  end
end
