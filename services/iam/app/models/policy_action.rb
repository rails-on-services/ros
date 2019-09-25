# frozen_string_literal: true

class PolicyAction < Iam::ApplicationRecord
  belongs_to :policy
  belongs_to :action
end
