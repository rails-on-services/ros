# frozen_string_literal: true

module Ros
  class LocustEndpointGenerator < Rails::Generators::NamedBase
    def create_files
      return unless model_defined?(name.classify)

      template(source, "#{destination}/#{name}.py", values)
      create_python_init_file(destination) unless python_init_file?(destination)
      create_python_init_file(lib_folder) unless python_init_file?(lib_folder)
    end

    private

    def create_python_init_file(destination)
      create_file "#{destination}/#{python_init_file_name}"
    end

    def model_defined?(name)
      Object.const_defined?(name)
    end

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
      'lib/core/lib/template/locust_endpoint.yml.erb'
    end

    def destination
      Ros.root.join("sre/lib/#{Settings.service.name}")
    end

    def lib_folder
      Ros.root.join('sre/lib')
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
        next "'#{key}': #{key}" if key.end_with? '_id'
        next "'#{key}': #{value.to_s.capitalize}" if boolean?(value)
        next "'#{key}': None" if value.nil?

        "'#{key}': #{value.to_json}"
      end

      build_json_string(string_attributes)
    end

    def boolean?(value)
      [true, false].include? value
    end
  end
end