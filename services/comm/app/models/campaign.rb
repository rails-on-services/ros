# frozen_string_literal: true

class Campaign < Comm::ApplicationRecord
  has_many :events
  has_many :templates

  before_save :set_base_url

  def set_base_url
    self.base_url ||= current_tenant.properties.fetch(:campaign_base_url, '')
  end
end
