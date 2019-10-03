# frozen_string_literal: true

require_relative './avro_builder.rb'

class AvroGenerator < Rails::Generators::Base
  DICTIONARY = {
    integer: 'int',
    string: 'string',
    datetime: 'string',
    jsonb: 'string'
  }.freeze

  def create_files
    Ros.table_names.each do |name|
      next unless model_defined?(name.classify)

      service_name ||= Settings.service.name
      singular_name = name.singularize

      create_file "doc/schemas/cloud_events/#{service_name}/#{singular_name}.avsc" do
        avro_builder = AvroBuilder.new(singular_name, service_name)
        JSON.pretty_generate avro_builder.build_model_attributes
      end
    end
  end

  private

  def model_defined?(name)
    Object.const_defined?(name)
  end
end
