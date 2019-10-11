# frozen_string_literal: true

class TemplateResource < Comm::ApplicationResource
  attributes(:name, :description, :content, :status)
  # has_one :campaign
end
