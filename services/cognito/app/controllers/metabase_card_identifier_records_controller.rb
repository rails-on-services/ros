# frozen_string_literal: true

class MetabaseCardIdentifierRecordsController < Cognito::ApplicationController
  def create
    card_identifier_record = MetabaseCardIdentifierRecord.new(card_identifier_record_params)
    if card_identifier_record.save
      render json: { data: card_identifier_record }
    else
      render json: { errors: card_identifier_record.errors.messages }
    end
  end

  private

  def card_identifier_record_params
    jsonapi_params.permit(%i[card_id uniq_identifier])
  end
end
