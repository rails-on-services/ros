# frozen_string_literal: true

class MetabaseCard < Cognito::ApplicationRecord
  validates :card_id, presence: true, uniqueness: true
  validates :identifier, presence: true, uniqueness: true
end
