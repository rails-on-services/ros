# frozen_string_literal: true

class GroupPolicyJoin < Ros::Iam::ApplicationRecord
  belongs_to :group
  belongs_to :policy

  after_create :add_policy_to_users
  after_destroy :remove_policy_from_users

  def add_policy_to_users
    group.users.each do |user|
      user.attached_policies[policy.name] ||= 0
      user.attached_policies[policy.name] += 1
      user.save
    end
  end

  def remove_policy_from_users
    group.users.each do |user|
      user.attached_policies[policy.name] -= 1
      user.attached_policies.delete(policy.name) if user.attached_policies[policy.name].zero?
      user.save
    end
  end
end
