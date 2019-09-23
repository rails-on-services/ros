class AvroGenerator < Rails::Generators::NamedBase
  DICTIONARY = {
    integer: 'int',
    string: 'string',
    datetime: 'string'
  }

  def create_files
    create_file "doc/schemas/cloud_events/#{service_name}/#{name}.avsc" do
      JSON.pretty_generate build_model_name_and_type
    end
  end

  private

  def model
    name.classify.constantize
  end

  def build_model_name_and_type
    {
      "name": "#{service_name}.#{name}",
      "type": 'record',
      "fields": build_attributes_json
    }
  end

  def build_attributes_json
    model_columns.map do |column|
      data_type = DICTIONARY[column.sql_type_metadata.type]
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
    Rails.application.class.module_parent_name.downcase
  end

  def column_required(column_name)
    return true if column_name == 'id'

    model.validators_on(column_name.to_sym).map(&:class).include? presence_validator
  end

  def presence_validator
    ActiveRecord::Validations::PresenceValidator
  end
end
