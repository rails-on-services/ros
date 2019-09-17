# frozen_string_literal: true

class UserRole < Iam::ApplicationRecord
  belongs_to :user
  belongs_to :role
end
