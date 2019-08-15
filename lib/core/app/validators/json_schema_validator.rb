# frozen_string_literal: true

require 'json_schemer'

class JsonSchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    schema_file = options.fetch(:schema)
    return unless validator

    errors = validator.validate(value).to_a
    return true if errors.empty?

    record.errors.add(attribute,
                      :json_schema_mismatch,
                      schema: schema_file, errors: errors)
  end

  private

  def validator(schema_file, record)
    return JSONSchemer.schema(schema_file) if schema_file

    record.errors.add(attribute, 'missing schema in validator')
    nil
  end
end
