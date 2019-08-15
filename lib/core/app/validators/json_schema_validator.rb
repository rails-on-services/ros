# frozen_string_literal: true

require 'json_schemer'

class JsonSchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    schema_file = options.fetch(:schema)
    validator = init_validator(schema_file, record)

    return unless validator

    errors = validator.validate(value).to_a
    return true if errors.empty?

    record.errors.add(attribute,
                      :json_schema_mismatch,
                      schema: schema_file, errors: errors)
  end

  private

  def init_validator(schema_file, record)
    return JSONSchemer.schema(schema_file) if schema_file && File.exist?(schema_file)

    record.errors.add(:validator, 'missing schema in validator')
    nil
  end
end
