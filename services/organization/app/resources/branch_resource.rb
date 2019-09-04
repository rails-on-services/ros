# frozen_string_literal: true

class BranchResource < Organization::ApplicationResource
  attributes :name, :properties

  belongs_to :org
end
