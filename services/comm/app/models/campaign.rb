# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates
end
