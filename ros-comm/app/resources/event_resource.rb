# frozen_string_literal: true

class EventResource < Comm::ApplicationResource
  attributes :send_at
  has_one :campaign
  has_one :provider
end
