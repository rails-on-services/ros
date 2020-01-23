# frozen_string_literal: true

class PolicyAction < Ros::Iam::ApplicationRecord
  belongs_to :policy
  belongs_to :action
end
