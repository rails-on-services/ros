# frozen_string_literal: true

module Storage
  class ApplicationRecord < ::ApplicationRecord
    self.abstract_class = true
  end
end
