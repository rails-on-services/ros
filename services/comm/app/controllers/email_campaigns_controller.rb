# frozen_string_literal: true

class EmailCampaignsController < ApplicationController

  def show
    render json: email_campaign
  end

  def create
    campaign = EmailCampaign.new(create_params.merge(campaign: current_campaign))
    external_campaign = MailchimpService.create_campaign(campaign: campaign)
    if external_campaign.errors.blank?
      campaign.external_id = external_campaign.id
      campaign.save!
      render json: campaign
    else
      render json: { errors: external_campaign.errors }
    end
  end

  def update
    render json: MailchimpService.create_campaign_content(campaign: email_campaign, raw_html: update_params[:raw_html])
  end

  def start
    render json: MailchimpService.start_campaign(campaign: email_campaign)
  end

  def status
    render json: MailchimpService.campaign_status(campaign: email_campaign)
  end

  def content
    render json: MailchimpService.show_campaign_content(campaign: email_campaign)
  end


  private

  def create_params
    params.require(:data).require(:attributes).permit(%i[name type from_name from_email preview_text audience_id subject])
  end

  def update_params
    params.require(:data).require(:attributes).permit(:raw_html)
  end

  def current_campaign
    @current_campaign ||= Campaign.find(params[:campaign_id])
  end

  def email_campaign
    current_campaign.email_campaigns.find(params[:id])
  end
end