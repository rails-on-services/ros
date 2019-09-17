# frozen_string_literal: true

class UserPool < ApplicationRecord
  belongs_to :user
  belongs_to :pool
end
