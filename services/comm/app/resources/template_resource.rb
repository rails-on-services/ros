# frozen_string_literal: true

class TemplateResource < Comm::ApplicationResource
  attributes :name, :description
  attributes :content, :status
  has_one :campaign

  filter :campaign_id
end
