# frozen_string_literal: true

module AssociationResource
  extend ActiveSupport::Concern

  def method_missing(method, *params)
    association = self.class.find_resource(method)
    return super if association.blank?

    association.call(self)
  rescue JsonApiClient::Errors::ApiError => e
    nil
  end

  def respond_to_missing?(method, include_private = false)
    !self.class.find_resource(method).blank? || super
  end

  # Returns new instance of the resource or nil
  # @model.resource(:resource)&.tap do {|resource| resource.name = 'name'; resource.save}
  def resource(name)
    resource_klass = _resource_class(name)
    return unless resource_klass

    resource_klass.new
  end

  # yields query for a given resource
  # @model.query_resource(:resource) {|query| query.where(some: 'hing')}
  def query_resource(name)
    resource_klass = _resource_class(name)
    return unless resource_klass

    query = yield resource_klass
    query.find
  rescue JsonApiClient::Errors::ApiError => e
    nil
  end

  private

  def _resource_class(name)
    association = self.class.find_resource(name)
    return if association.nil?

    association._resource_class(self)
  end

  class_methods do
    def resource_associations
      @resource_associations ||= []
    end

    # Adds link to external ONE_ONE association.
    # :resource_name required. Model will respond this name to query external resource
    # :class_name required for non-polymorphic associations. Should respond to `where` and `find`
    def belongs_to_resource(resource_name, class_name: nil, foreign_key: nil, polymorphic: false)
      return unless find_resource(resource_name).blank?

      resource_associations << BelongsToResource.new(
        name: resource_name,
        class_name: class_name,
        foreign_key: foreign_key,
        polymorphic: polymorphic
      )
    end

    # Adds link to external ONE_MANY association.
    # :resource_name required. Model will respond this name to query external resources
    # :class_name required. Should respond to `where` and `find`
    # :as represents polymorphic relation. type will be added to query:
    #   User.has_many_resources(:some_resource, class_name: 'Some::Resource', as: :external) ->
    #      Some::Resource.where(external_type: 'User', external_id: user.id)
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
