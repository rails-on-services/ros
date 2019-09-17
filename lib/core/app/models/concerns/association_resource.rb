# frozen_string_literal: true

module AssociationResource
  extend ActiveSupport::Concern

  def method_missing(method, *params)
    return super if self.class.find_resource(method).blank?

    self.class.find_resource(method).call(self)
  end

  def respond_to_missing?(method, include_private = false)
    !self.class.find_resource(method).blank? || super
  end

  class_methods do
    def resource_associations
      @resource_associations ||= []
    end

    def belongs_to_resource(resource_name, class_name: nil, foreign_key: nil, polymorphic: false)
      return unless find_resource(resource_name).blank?

      resource_associations << BelongsToResource.new(
        name: resource_name,
        class_name: class_name,
        foreign_key: foreign_key,
        polymorphic: polymorphic
      )
    end

    def has_many_resources(resource_name, class_name:, foreign_key: nil, as: nil)
      return unless find_resource(resource_name).blank?

      resource_associations << HasManyResources.new(
        name: resource_name,
        class_name: class_name,
        foreign_key: foreign_key,
        associated_name: as
      )
    end

    def find_resource(resource_name)
      resource_associations.find { |resource| resource.name == resource_name }
    end
  end
end