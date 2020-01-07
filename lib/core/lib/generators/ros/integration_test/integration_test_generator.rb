# frozen_string_literal: true

module Ros
  class IntegrationTestGenerator < Rails::Generators::NamedBase
    def create_files
      template(source, "#{destination}/#{name}.py", values)
    end

    private

    def source_paths
      [Ros.root, Ros.root.join('ros')]
    end

    def source
      'lib/core/lib/template/integration_test.yml.erb'
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
