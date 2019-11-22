# frozen_string_literal: true

module Metabase
  class CardMap
    include ActiveModel::Model

    attr_reader :identifier
    attr_accessor :errors

    validate :card_present

    def initialize(identifier:)
      @identifier = identifier
    end

    def mapped_value
      return unless valid?

      card_identifer_record.card_id
    end

    private

    def card_present
      errors.add(:card_id, 'not present') unless card_identifer_record.present?
    end

    def card_identifer_record
      MetabaseCardIdentifierRecord.find_by(uniq_identifier: identifier)
    end
  end
end
