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
end
