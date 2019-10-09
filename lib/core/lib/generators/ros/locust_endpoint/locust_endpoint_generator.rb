# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class LocustEndpointGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      template(source, "#{destination}/#{name}.py", values)
      create_file "#{destination}/#{python_init_file_name}" unless python_init_file?(destination)
    end

    private

    def python_init_file_name
      '__init__.py'
    end

    def python_init_file?(destination)
      File.exist? destination.join(python_init_file_name)
    end

    def source_paths
      [Ros.root, Ros.root.join('ros')]
    end

    def source
      'lib/core/lib/template/locust.yml.erb'
    end

    def destination
      Ros.root.join("lib/sre/lib/#{Settings.service.name}")
    end

    def values
      OpenStruct.new(
        service_name: Settings.service.name,
        class_name: class_name,
        name: name,
        plural_name: plural_name,
        extra_args: extra_args,
        payload: payload
      )
    end

    def class_name
      "#{Settings.service.name.classify}#{name.classify}"
    end

    def model
      FactoryBot.build(name.to_sym)
    end

    def required_attributes
      args = %w[id created_at updated_at]
      model.attributes.except(*args)
    end

    def extra_args
      associations_attributes = model.attributes.select { |attribute| attribute.end_with?('_id') }
      associations_attributes.keys.join(', ')
    end

    def build_json_string(attributes)
      "{ 'data': { 'type': '#{plural_name}', 'attributes': { #{attributes.join(', ')} } } }"
    end

    def payload
      string_attributes = required_attributes.map do |key, value|
        next "'#{key}': #{value.to_json}" unless key.end_with? '_id'

        "'#{key}': #{key}"
      end

      build_json_string(string_attributes)
    end
  end
end
