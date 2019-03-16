# frozen_string_literal: true

module Ros
  module Routes
    def catch_not_found
      match '*path', controller: 'application', action: :not_found, via: :all
    end
    # def cache(*resources)
    #   resources.each do |resource|
    #     get "#{resource}_cache", to: "#{resource}#cache"
    #   end
    # end

    # def report(*resources)
    #   resources.each do |resource|
    #     get "#{resource}_reports", to: "#{resource}#reports"
    #   end
    # end
  end
end
