# frozen_string_literal: true

class Pool < Cognito::ApplicationRecord
  has_many :user_pools
  has_many :users, through: :user_pools
end
