# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates

  has_many :audience
  has_many :email_campaigns
  belongs_to_resource :owner, polymorphic: true
  belongs_to_resource :cognito_endpoint, class_name: 'Ros::Cognito::Endpoint'

  before_save :set_base_url

  def set_base_url
    # https://{{tenant}}-blackcomb-sales.uat.whistler.perxtech.io/
    self.base_url ||= current_tenant.properties.fetch(:campaign_base_url, '')
  end

  def final_url
    "#{base_url}loading/"
  end
end
