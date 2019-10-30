# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ControllerGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      template(source, "app/controllers/#{plural_name}_controller.rb", values)
    end

    private

    def values
      OpenStruct.new(
        name: plural_name.capitalize,
        parent_module: parent_module
      )
    end

    def source
      'lib/core/lib/template/controller.yml.erb'
    end

    def source_paths
      [Ros.root, Ros.root.join('ros')]
    end
  end
end
