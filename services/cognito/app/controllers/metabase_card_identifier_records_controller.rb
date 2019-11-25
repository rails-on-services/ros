# frozen_string_literal: true

class MetabaseCardIdentifierRecordsController < Cognito::ApplicationController
  before_action :load_record_creator

  def create
    card_identifier_record = MetabaseCardIdentifierRecord.new(card_identifier_record_params)
    if card_identifier_record.save
      render json: {data: card_identifier_record}
    else
      render json: {errors: card_identifier_record.errors.messages}
    end
  end

  private

  def card_identifier_record_params
    params(:metabase_card_identifier_record).permit(:card_id, :uniq_identifier)
  end
end
