# frozen_string_literal: true

class OrgResource < Organization::ApplicationResource
  attributes :name, :description, :properties

end
