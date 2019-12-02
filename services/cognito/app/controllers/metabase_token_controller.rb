# frozen_string_literal: true

class MetabaseTokenController < Cognito::ApplicationController
  DEFAULT_TYPE = 'question'

  before_action :identify_resource, only: :show

  def show
    tokenizer = Metabase::TokenGenerator.new(payload: payload, expiry: params[:expiry])
    if tokenizer.valid?
      render json: { token: tokenizer.token }, root: :data
    else
      render json: { errors: tokenizer.errors.messages }, status: 422
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

  def identify_resource
    return params if /^\d+$/.match?(params[:id])

    card = MetabaseCard.find_by(identifier: params[:id])
    if card.nil?
      render json: { errors: 'Card not found'}, status: 404
      return
    end

    params[:id] = card.card_id
  end
end
