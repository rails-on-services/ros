# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates
  belongs_to :owner, polymorphic: true
end
