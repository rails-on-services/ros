# frozen_string_literal: true

module JsonApiSpecHelper
  def jsonapi_data(object, options = {})
    remove = options.fetch(:remove, false)
    skip_attributes = options.fetch(:skip_attributes, [])
    method = options.fetch(:method, :get)

    args = %i[id created_at updated_at]
    skip_attributes.append(*args) if remove

    data = {
      type: object.class.name.underscore.pluralize,
      attributes: object.attributes.except(*skip_attributes.map(&:to_s))
    }
    data[:id] = object.id if %i[put patch].include?(method.downcase.to_sym)

    { data: data }.to_json
  end

  def jsonapi_data_with_nested_resources(object, nested_resource, remove = false)
    model_jsonapi = JSON.parse(jsonapi_data(object, remove: remove))
    model_jsonapi['data']['attributes'].merge!(nested_resource)
    model_jsonapi.to_json
  end
end
