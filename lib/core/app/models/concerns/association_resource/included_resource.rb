# frozen_string_literal: true

# Class represents any included external resource.
# All returned fields will be included in the response
# Resource type will be matched dynamically
module AssociationResource
  class IncludedResource < Ros::ApplicationResource
    immutable
    cattr_accessor :sub_name

    def initialize(model, context)
      reload_attributes!
      self.class._type = model.class.name
      self.class.attributes(*extract_attributes(model))
      self.class.attribute(:id, format: :default)
      super
    end

    def custom_links(_options)
      {
        self: _model&.url
      }
    end

    def self._model_class
      _type
    end

    def included?
      true
    end

    # While each resource class created dynamically from Class.new
    # And resource type is created from class name after inherited callback
    # And inherited callback is called before class initialization
    # we have to set name for Class.new (Class.new(Parent).name => nil)
    # and extract Class.name from this class attribute
    def self.inherited(subclass)
      subclass.instance_variable_set(:@name, sub_name) if sub_name.present?
      super
    end

    def self.name
      instance_variable_get(:@name) || super
    end

    private

    def extract_attributes(model)
      model.attributes.except(:id, :type).symbolize_keys.keys.compact
    end

    def reload_attributes!
      self.class._attributes = {}
      self.class._type = nil
    end
  end
end
