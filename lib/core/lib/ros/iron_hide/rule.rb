# frozen_string_literal: true

module IronHide
  class Rule

    def self.find(user, action, resource)
      cache = IronHide.configuration.memoizer.new
      ns_resource = "#{IronHide.configuration.namespace}::#{resource.class.name}"
      # NOTE: modified to pass the user into the storage adapter
      storage.where(user: user, resource: ns_resource, action: action).map do |json|
        new(user, resource, json, cache)
      end
    end
  end
end
