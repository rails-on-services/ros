# frozen_string_literal: true

class EventResource < Comm::ApplicationResource
  attributes :name, :send_at, :provider_id, :campaign_id, :template_id, :channel, :pool_id
  attributes :target_type, :target_id, :owner_type, :owner_id

  has_one :provider
  has_one :template

  filters :owner_type, :owner_id

  def fetchable_fields
    super - %i[pool_id]
  end

  def pool_id=(pool_id)
    @model.target_type = 'Ros::Cognito::Pool'
    @model.target_id = pool_id
  end

  before_save do
    # TODO: Make this a valid provider
    @model.provider_id ||= 1
  end
end
