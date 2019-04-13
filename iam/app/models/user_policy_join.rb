# frozen_string_literal: true

class UserPolicyJoin < ApplicationRecord
  belongs_to :user
  belongs_to :policy

  after_create :add_policy_to_user
  after_destroy :remove_policy_from_user

  def add_policy_to_user
    user.attached_policies[policy.name] ||= 0
    user.attached_policies[policy.name] += 1
    user.save
  end

  def remove_policy_from_user
    user.attached_policies[policy.name] -= 1
    user.attached_policies.delete(policy.name) if user.attached_policies[policy.name].zero?
    user.save
  end
end
