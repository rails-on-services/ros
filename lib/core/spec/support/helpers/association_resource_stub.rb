# frozen_string_literal: true

module AssociationResource
  module Stub
    def stubbed_resource(resource:, attributes:)
      attributes = [attributes] unless attributes.is_a? Array

      allow(resource).to receive(:find).and_return attributes
      allow(resource).to receive(:all).and_return attributes
      allow(resource).to receive(:where).and_return resource
      allow(resource).to receive(:includes).and_return resource
    end

    def stub_resource(model:, resource:, attributes:)
      # TODO: checks resource exists on given model
      association = model.find_resource(resource)
      resource_class = extract_resource_class(association)

      allow(association).to receive(:call).with(an_instance_of(model)).and_return resource_class.new(attributes)
    end

    def unstub_resource(model:, resource:)
      # TODO: checks resource exists on given model
      association = model.find_resource(resource)
      # TODO: add ability for polymorphic
      return if association.polymorphic

      allow(association).to receive(:call).with(an_instance_of(model)).and_call_original
    end

    def extract_resource_class(association)
      return OpenStruct if association.polymorphic

      association.class_name.safe_constantize
    end
  end
end

RSpec.configure do |c|
  c.include AssociationResource::Stub
end
