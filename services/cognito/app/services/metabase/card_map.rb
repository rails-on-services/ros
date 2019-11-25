# frozen_string_literal: true

module Metabase
  class CardMap
    include ActiveModel::Model

    attr_reader :identifier
    attr_accessor :errors

    def initialize(identifier:)
      @identifier = identifier
    end

    def mapped_value
      return if card_identifier_record.blank?

      card_identifier_record.card_id
    end

    def card_identifier_record
      MetabaseCardIdentifierRecord.find_by(uniq_identifier: identifier)
    end
  end
end
