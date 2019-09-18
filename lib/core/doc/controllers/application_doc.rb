# frozen_string_literal: true

# NOTE: Postman does not like type 'application/vnd.api+json'
# resp 200, 'success', 'application/vnd.api+json', data: { data: [{id: 1}] }

module AutoGenDoc
  def self.included(base)
    base.extend ClassMethods
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  module ClassMethods
    def inherited(subclass)
      subclass.class_eval do
        api_dry :index do
          header :Authorization, String
          # auth :Authorization
          # base_auth :BasicAuth, desc: 'basic auth' # the same effect as above
          # security_scheme :BasicAuth, { type: 'http', scheme: 'basic', desc: 'basic auth' }
          # bearer_auth :Token, format = 'JWT', other_info = { }
          # TODO: range is what is causing the error on Postman
          query 'page[number]', Integer # , false, range: { ge: 1 } #, default: 1
          query 'page[size]', Integer # , range: { ge: 1 }, default: 1
          query :sort, String
          query :include, String
          (subclass.resource_class.filters.keys - %i[id]).each do |field|
            query "filter[#{field}]", String, desc: subclass.resource_class.descriptions[field] || nil
          end
          response 200, :success, :json, data: JSONAPI::ResourceSerializer.new(subclass.resource_class)
                                                                          .serialize_to_hash(subclass.resources).to_json
          response 401, :unauthorized, :json, data: {
            'errors': [
              {
                'status': '401',
                'title': 'Unauthorized'
              }
            ]
          }
        end

        api_dry :show do
          header :Authorization, String
          response 200, :success, :json, data: JSONAPI::ResourceSerializer.new(subclass.resource_class)
                                                                          .serialize_to_hash(subclass.resource).to_json
          response 401, :unauthorized, :json, data: {
            'errors': [
              {
                'status': '401',
                'title': 'Unauthorized'
              }
            ]
          }
        end

        api_dry :create do
          header :Authorization, String # , 'Basic access_key_id:secret_access_key'
          attributes = subclass.resource_class._attributes.except(:id, :urn, :created_at, :updated_at)
          attributes.each_key { |k| attributes[k] = String }
          body 'application/vnd.api+json', data: {
            data: {
              xyz_type: subclass.model_name.underscore.pluralize,
              attributes: attributes
            }
          }
          response 200, :success, :json, data: JSONAPI::ResourceSerializer.new(subclass.resource_class)
                                                                          .serialize_to_hash(subclass.resource).to_json
          response 401, :unauthorized, :json, data: {
            'errors': [
              {
                'status': '401',
                'title': 'Unauthorized'
              }
            ]
          }
        end

        api_dry :update do
          header :Authorization, String
          # path :id, Integer
          attributes = subclass.resource_class._attributes.except(:id, :urn, :created_at, :updated_at)
          attributes.each_key { |k| attributes[k] = String }
          body 'application/vnd.api+json', data: {
            data: {
              xyz_type: subclass.model_name.underscore.pluralize,
              attributes: attributes
            }
          }
          response 200, :success, :json, data: JSONAPI::ResourceSerializer.new(subclass.resource_class)
                                                                          .serialize_to_hash(subclass.resource).to_json
          response 401, :unauthorized, :json, data: {
            'errors': [
              {
                'status': '401',
                'title': 'Unauthorized'
              }
            ]
          }
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength
end

class ApplicationDoc
  include OpenApi::DSL
  include AutoGenDoc
  class << self
    # TODO: Provide various contexts rather than default to nil; maybe
    def resource
      model = model_class.first || FactoryBot.create(model_name.underscore.to_sym)
      resource_class.new(model, nil)
    end

    def resources
      2.times { FactoryBot.create(model_name.underscore.to_sym) } if model_class.count.zero?
      model_class.all.limit(2).map { |record| resource_class.new(record, nil) }
    end

    def resource_class; resource_name.constantize end

    def resource_name; name.remove('Doc') end

    def model_class; model_name.constantize end

    def model_name; name.remove('ResourceDoc') end
  end
end

require_relative 'tenant_resource_doc'
