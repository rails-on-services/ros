# frozen_string_literal: true

class TemplateResource < Comm::ApplicationResource
  attributes(:name, :description, :content, :status)
end
