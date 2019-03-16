# frozen_string_literal: true

class Group < Iam::ApplicationRecord
  has_many :group_policies, class_name: 'GroupPolicyJoin'
  has_many :policies, through: :group_policies
  has_many :actions, through: :policies

  has_many :user_groups
  has_many :users, through: :user_groups
  has_many :user_actions, through: :users, source: :actions

  def urn_id
    "group/#{name}"
  end
end
