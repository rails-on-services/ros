# frozen_string_literal: true

module Ros
  module Routes
    def catch_not_found
      match '*path', controller: 'application', action: :not_found, via: :all
    end
  end
end
