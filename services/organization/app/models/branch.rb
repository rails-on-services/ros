# frozen_string_literal: true

class Branch < Organization::ApplicationRecord
  belongs_to :org
end
