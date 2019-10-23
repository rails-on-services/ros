# frozen_string_literal: true

class AvroBuilder
  DICTIONARY = {
    bigint: 'int',
    integer: 'int',
    string: 'string',
    text: 'string',
    datetime: 'long',
    jsonb: 'string',
    float: 'double',
    boolean: 'boolean'
  }.freeze

  def initialize(name, service_name)
    @name = name
    @service_name = service_name
  end

  def build_model_attributes
    {
      "name": "#{@service_name}.#{@name}",
      "type": 'record',
      "fields": build_attributes_json
    }
  end

  private

  def model
    @name.classify.constantize
  end

  def build_attributes_json
    all_attributes = model_columns.map do |column|
      next { name: column.name, type: 'int' } if column.name == 'id'

      data_type = DICTIONARY[column.sql_type_metadata.type] || 'string'
      attribute_hash(column.name, data_type)
    end

    all_attributes.push(attribute_hash('urn', 'string'))
  end

  def attribute_hash(column_name, data_type)
    {
      "name": column_name,
      "type": ['null', data_type],
      "default": nil
    }
  end

  def urn
    {
      "name": 'urn',
      "type": %w[null string],
      "default": nil
    }
  end

  def model_columns
    model.columns
  end
end
