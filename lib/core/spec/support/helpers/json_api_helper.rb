# frozen_string_literal: true

module JsonApiSpecHelper
  def jsonapi_data(object, options = {})
    extra_attributes = options.fetch(:extra_attributes, {})
    skip_attributes = options.fetch(:skip_attributes, [])
    method = options.fetch(:method, :get)
    relations = Array.wrap(options[:relationships])

    generic_attributes = %i[id created_at updated_at deleted_at]
    skip_attributes.append(*generic_attributes)

    data = {
      type: object.class.name.underscore.pluralize,
      attributes: object.attributes.except(*skip_attributes.map(&:to_s)).merge(extra_attributes)
    }
    data[:id] = object.id if %i[put patch].include?(method.downcase.to_sym)
    relation_hash = {}
    relations.each do |relation|
      name = relation[:name]
      type = relation[:type] || name.to_s.pluralize
      id = relation[:id]
      next unless id && type

      relation_hash[name] = {
        data: {
          type: type,
          id: id
        }
      }
    end

    data[:relationships] = relation_hash if relation_hash.present?

    { data: data }.to_json
  end
end
