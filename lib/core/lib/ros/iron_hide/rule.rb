# frozen_string_literal: true

module IronHide
  class Rule
    def self.find(user, action, resource)
      cache = IronHide.configuration.memoizer.new
      ns_resource = "#{ApplicationRecord.urn_base}*:*:#{resource.class.name.downcase}"
      # ns_resource = resource.class.to_urn
      # NOTE: modified to pass the user into the storage adapter
      ar = storage.where(user: user, resource: ns_resource, action: action).map do |json|
        new(user, resource, json, cache)
      end
        binding.pry
        ar
    end
  end
end
