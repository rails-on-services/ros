# frozen_string_literal: true

module Ros
  class LocustGenerator < Rails::Generators::NamedBase
    def create_files
      source = 'ros/lib/core/lib/template/locust.yml.erb'
      destination = "../../lib/sre/lib/#{Settings.service.name}/#{name}.py"

      template(source, destination, values)
    end

    private

    def source_paths
      [ Rails.root.join('../..') ]
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
