# frozen_string_literal: true

class Policy < Iam::ApplicationRecord
  has_many :policy_actions
  has_many :actions, through: :policy_actions

  has_many :user_policy_joins
  has_many :group_policy_joins
  has_many :role_policy_joins
end
