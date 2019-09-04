# frozen_string_literal: true

class Org < Organization::ApplicationRecord
  has_many :branches
end
