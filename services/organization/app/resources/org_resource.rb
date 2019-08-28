# frozen_string_literal: true

class OrgResource < Organization::ApplicationResource
  attributes :name, :description, :properties, :display_properties
  has_one 
end
