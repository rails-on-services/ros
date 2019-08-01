# frozen_string_literal: true

class AudienceController < ApplicationController

  def show
    render json: MailchimpService.show_members(list: audience)
  end

  def create
    list = Audience.new(create_params.merge(campaign: current_campaign))
    external_list = MailchimpService.create_list(list: list)
    if external_list.errors.blank?
      list.external_id = external_list.id
      list.save!
      render json: list
    else
      render json: { errors: external_list.errors }
    end
  end

  def update
    render json: MailchimpService.create_members(list: audience, members: update_params[:audience])
  end

  private

  def create_params
    params.require(:data).require(:attributes).permit(audience_attributes)
  end

  def update_params
    params.require(:data).require(:attributes).permit(audience: %i[first_name last_name email])
  end

  def audience_attributes
    %i[name company_name address city state zip country phone reminder
       from_name from_email subject language]
  end

  def current_campaign
    @current_campaign ||= Campaign.find(params[:campaign_id])
  end

  def audience
    current_campaign.audience.find(params[:id])
  end


end