# frozen_string_literal: true

class AvroBuilder
  DICTIONARY = {
    integer: 'int',
    string: 'string',
    datetime: 'string',
    jsonb: 'string'
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
    model_columns.map do |column|
      data_type = DICTIONARY[column.sql_type_metadata.type] || 'string'
      type = column_required(column.name) ? data_type : ['null', data_type]

      {
        "name": column.name,
        "type": type
      }
    end
  end

  def model_columns
    model.columns
  end

  def column_required(column_name)
    return true if column_name == 'id'

    model.validators_on(column_name.to_sym).map(&:class).include? presence_validator
  end

  def presence_validator
    ActiveRecord::Validations::PresenceValidator
  end
end
