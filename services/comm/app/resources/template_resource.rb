# frozen_string_literal: true

class TemplateResource < Comm::ApplicationResource
  attributes(:name, :description, :content, :status, :campaign_entity_id)
  # has_one :campaign

  filter :campaign_entity_id
end
