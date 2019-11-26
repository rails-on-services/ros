# frozen_string_literal: true

class MetabaseTokenController < Cognito::ApplicationController
  DEFAULT_TYPE = 'question'

  def show
    tokenizer = Metabase::TokenGenerator.new(payload: payload, expiry: params[:expiry])
    if tokenizer.valid?
      render json: { token: tokenizer.token }, root: :data
    else
      render json: { errors: tokenizer.errors.messages }
    end
  end

  def show_identifier
    identifier = params.delete(:identifier)
    card = MetabaseCard.find_by(identifier: identifier)
    if card.nil?
      render json: { errors: 'Card ID not found' }
      return
    end

    params[:id] = card.card_id
    show
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
end
