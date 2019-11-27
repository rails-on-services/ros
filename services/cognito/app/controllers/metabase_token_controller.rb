# frozen_string_literal: true

class MetabaseTokenController < Cognito::ApplicationController
  DEFAULT_TYPE = 'question'

  before_action :identify_resource, only: :show

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
      resource: { type => params[:id] },
      params: payload_params
    }
  end

  def payload_params
    options = { tenant: Apartment::Tenant.current }
    return options if params[:params].blank?

    options.merge(params[:params].to_unsafe_h.deep_symbolize_keys)
  end

  def identify_resource
    params[:id] = if identifier.is_a? Numeric
                    identifier.to_i
                  else
                    card_id = MetabaseCard.find_by(identifier: identifier).id
                    render json: { errors: 'Card not found' } if card_id.nil?
                  end
  end
end
