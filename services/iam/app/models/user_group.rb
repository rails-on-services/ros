# frozen_string_literal: true

class UserGroup < Iam::ApplicationRecord
  belongs_to :user
  belongs_to :group

  after_create :add_policies_to_user
  after_destroy :remove_policies_from_user

  def add_policies_to_user
    group.policies.each do |policy|
      user.attached_policies[policy.name] ||= 0
      user.attached_policies[policy.name] += 1
    end
    user.save
  end

  # rubocop:disable Metrics/AbcSize
  def remove_policies_from_user
    group.policies.each do |policy|
      user.attached_policies[policy.name] -= 1
      user.attached_policies.delete(policy.name) if user.attached_policies[policy.name].zero?
    end
    user.save
  end
  # rubocop:enable Metrics/AbcSize
end
