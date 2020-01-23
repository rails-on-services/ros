# frozen_string_literal: true

class RolePolicyJoin < Ros::Iam::ApplicationRecord
  belongs_to :role
  belongs_to :policy
end
