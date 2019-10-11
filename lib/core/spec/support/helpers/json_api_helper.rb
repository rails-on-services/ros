# frozen_string_literal: true

module JsonApiSpecHelper
  def jsonapi_data(object, options = {})
    extra_attributes = options.fetch(:extra_attributes, {})
    skip_attributes = options.fetch(:skip_attributes, [])
    method = options.fetch(:method, :get)

    generic_attributes = %i[id created_at updated_at]
    skip_attributes.append(*generic_attributes)

    data = {
      type: object.class.name.underscore.pluralize,
      attributes: object.attributes.except(*skip_attributes.map(&:to_s)).merge(extra_attributes)
    }
    data[:id] = object.id if %i[put patch].include?(method.downcase.to_sym)

    { data: data }.to_json
  end
end
