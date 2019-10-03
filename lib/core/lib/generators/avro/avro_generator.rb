# frozen_string_literal: true

class AvroGenerator < Rails::Generators::Base
  DICTIONARY = {
    integer: 'int',
    string: 'string',
    datetime: 'string',
    jsonb: 'string'
  }.freeze

  def create_files
    Ros.table_names.each do |name|
      next unless Object.const_defined?(name.classify)

      @name = name

      create_file "doc/schemas/cloud_events/#{service_name}/#{name.singularize}.avsc" do
        JSON.pretty_generate build_model_name_and_type
      end
    end
  end

  private

  def model_defined?(name)
    Object.const_defined?(name)
  end

  def model
    @name.classify.constantize
  end

  def build_model_name_and_type
    {
      "name": "#{service_name}.#{@name.singularize}",
      "type": 'record',
      "fields": build_attributes_json
    }
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

  def service_name
    @service_name ||= Settings.service.name
  end

  def column_required(column_name)
    return true if column_name == 'id'

    model.validators_on(column_name.to_sym).map(&:class).include? presence_validator
  end

  def presence_validator
    ActiveRecord::Validations::PresenceValidator
  end
end
