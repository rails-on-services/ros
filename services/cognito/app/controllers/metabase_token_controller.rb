# frozen_string_literal: true

class MetabaseTokenController < Cognito::ApplicationController
  DEFAULT_TYPE = 'question'

  before_action :map_identifier_to_id, only: :show

  def show
    tokenizer = Metabase::TokenGenerator.new(payload: payload, expiry: params[:expiry])
    if tokenizer.valid?
      render json: { token: tokenizer.token }, root: :data
    else
      render json: { errors: tokenizer.errors.messages }
    end
  end

  private

  def payload
    type = params.delete(:type) || DEFAULT_TYPE

    {
      resource: { type => params[:id].to_i },
      params: payload_params
    }
  end

  def payload_params
    options = { tenant: Apartment::Tenant.current }
    return options if params[:params].blank?

    options.merge(params[:params].to_unsafe_h.deep_symbolize_keys)
  end

  def map_identifier_to_id
    return if params[:identifier].blank?

    if card_map.card_identifier_record.present?
      params[:id] = card_map.mapped_value
    else
      render json: { errors: 'Card ID not found' }
    end
  end

  def card_map
    Metabase::CardMap.new(identifier: params[:identifier])
  end
end
