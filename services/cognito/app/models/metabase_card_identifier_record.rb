# frozen_string_literal: true

class MetabaseCardIdentifierRecord < Cognito::ApplicationRecord
  validates :card_id, presence: true
  validates :uniq_identifier, presence: true, uniqueness: true
end
