# frozen_string_literal: true

class TemplateResource < Comm::ApplicationResource
  attributes :content, :status
  has_one :campaign
end
