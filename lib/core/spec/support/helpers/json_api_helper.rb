# frozen_string_literal: true

module JsonApiSpecHelper
  def jsonapi_data(object, remove = false, *except_attributes)
    args = %i[id created_at updated_at]
    except_attributes.append(*args) if remove
    {
      data: {
        type: object.class.name.underscore.pluralize,
        attributes: object.attributes.except(*except_attributes.map(&:to_s))
      }
    }.to_json
  end

  def jsonapi_data_with_nested_resources(object, nested_resource, remove = false)
    model_jsonapi = JSON.parse(jsonapi_data(object, remove))
    model_jsonapi['data']['attributes'].merge!(nested_resource)
    model_jsonapi.to_json
  end
end
