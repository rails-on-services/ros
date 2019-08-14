# frozen_string_literal: true

require 'json-schema'

class JsonSchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    schema_file = options.fetch(:schema)
    return unless schema_file_present?(schema_file, record)

    errors = JSON::Validator.fully_validate(schema_file.to_s, value, strict: true)
    return true if errors.empty?

    record.errors.add(attribute,
                      :json_schema_mismatch,
                      schema: schema_file, errors: errors)
  end

  private

  def schema_file_present?(schema_file, record)
    return true if schema_file

    record.errors.add(attribute, 'missing schema in validator')
    false
  end
end
