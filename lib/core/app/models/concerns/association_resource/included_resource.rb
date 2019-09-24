# frozen_string_literal: true

# Class represents any included external resource.
# All returned fields will be included in the response
# Resource type will be matched dynamically
module AssociationResource
  class IncludedResource < Ros::ApplicationResource
    immutable

    def initialize(model, context)
      reload_attributes!
      self.class._type = model.class.name
      self.class.attributes(*extract_attributes(model))
      self.class.attribute(:id, format: :default)
      super
    end

    private

    def extract_attributes(model)
      model.attributes.except(:type, :id).symbolize_keys.keys.compact
    end

    def reload_attributes!
      self.class._attributes = {}
      self.class._type = nil
    end
  end
end