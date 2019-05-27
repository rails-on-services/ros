# frozen_string_literal: true

class EventResource < Comm::ApplicationResource
  attributes :name, :send_at, :provider_id, :campaign_id, :template_id, :channel
  attributes :target_type, :target_id
  has_one :campaign
  has_one :provider
  has_one :template

  filter :campaign_id
end
