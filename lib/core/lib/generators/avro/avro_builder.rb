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
    decimal: 'string',
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

      attribute_hash(column.name, data_type(column))
    end

    all_attributes.push(*optional_attributes)
  end

  def data_type(column)
    case column.sql_type_metadata.type
    when :datetime
      {
        "type": DICTIONARY[column.sql_type_metadata.type],
        "logicalType": 'timestamp-millis'
      }
    else
      DICTIONARY[column.sql_type_metadata.type] || 'string'
    end
  end

  def attribute_hash(column_name, data_type)
    {
      "name": column_name,
      "type": ['null', data_type],
      "default": nil
    }
  end

  def model_columns
    model.columns
  end

  def optional_attributes
    [
      attribute_hash('urn', 'string'),
      attribute_hash('_op', 'string')
    ]
  end
end
