# frozen_string_literal: true

require 'json_schemer'

class JsonSchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    schema_file = options.fetch(:schema)
    validator = init_validator(schema_file)

    if validator
      result = validator.validate(value).to_a
      return true if result.empty?

      record.errors.add(attribute,
                        :json_schema_mismatch,
                        schema: schema_file, errors: result[0]["details"])
    else
      record.errors.add(:validator, 'missing schema in validator')
    end
  end

  private

  def init_validator(schema_file)
    return JSONSchemer.schema(schema_file) if schema_file && File.exist?(schema_file)
  end
end
