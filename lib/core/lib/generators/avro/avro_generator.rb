# frozen_string_literal: true

require_relative './avro_builder.rb'

class AvroGenerator < Rails::Generators::NamedBase
  def create_files
    return unless model_defined?(name.classify)

    service_name = Settings.service.name

    create_file "#{Settings.event_logging.config.schemas_path}/#{service_name}/#{name}.avsc" do
      avro_builder = AvroBuilder.new(name, service_name)
      JSON.pretty_generate avro_builder.build_model_attributes
    end
  end

  private

  def model_defined?(classified_name)
    Ros.table_names.include?(plural_name) && Object.const_defined?(classified_name)
  end
end
