# frozen_string_literal: true

class UserRole < Ros::Iam::ApplicationRecord
  belongs_to :user
  belongs_to :role
end
