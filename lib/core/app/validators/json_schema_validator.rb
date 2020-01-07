# frozen_string_literal: true

require 'json_schemer'

class JsonSchemaValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    schema_file = options.fetch(:schema)
    validator = init_validator(schema_file)

    if validator.nil?
      record.errors.add(:validator, 'missing schema in validator')
      return false
    end

    result = validator.validate(value).to_a
    return true if result.empty?

    record.errors.add(attribute, :json_schema_mismatch,
                      schema: schema_file, errors: errors(result),
                      errors_summary: errors_summary(result))
  end

  private

  def init_validator(schema_file)
    return nil unless schema_file && File.exist?(schema_file)

    JSONSchemer.schema(schema_file)
  end

  def fallback_error(result)
    "'#{result[0]['data_pointer'].gsub(%r{^\/}, '')}' property is invalid"
  end

  def errors(result)
    details = result[0]['details']

    details.nil? ? fallback_error(result) : details
  end

  def errors_summary(result)
    details = result[0]['details']

    if details.nil?
      fallback_error(result)
    else
      details.map { |k, v| "#{k}: #{v.is_a?(Array) ? v.join(', ') : v}" }.join('; ')
    end
  end
end
