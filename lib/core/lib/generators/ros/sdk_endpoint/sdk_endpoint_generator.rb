# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class SdkEndpointGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      repo = engine? ? 'ros' : 'perx'
      service_name = Settings.service.name.underscore
      file_path = "../../lib/sdk/lib/#{repo}_sdk/models/#{service_name}.rb"

      insert_into_file file_path, before: "  end\n" do
        "    class #{name.classify} < Base; end\n"
      end
    end
  end
end
