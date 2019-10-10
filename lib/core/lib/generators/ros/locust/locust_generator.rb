# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class LocustGenerator < Rails::Generators::Base
    include GeneratorsHelper

    def create_files
      template(source, "#{destination}/#{Settings.service.name}.py", values)
    end

    private

    def source_paths
      [Ros.root, Ros.root.join('ros')]
    end

    def source
      'lib/core/lib/template/locust.yml.erb'
    end

    def destination
      Ros.root.join('sre/integration_test')
    end

    def values
      OpenStruct.new(
        service_name: Settings.service.name.classify
      )
    end
  end
end
