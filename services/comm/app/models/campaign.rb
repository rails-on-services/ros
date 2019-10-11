# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates

  def base_url
    @base_url || current_tenant.properties.campaign_base_url
  end
end
