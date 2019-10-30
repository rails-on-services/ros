# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class SdkEndpointGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      repo = engine? ? 'ros' : 'perx'
      file_path = "../../lib/sdk/lib/#{repo}_sdk/models/#{Settings.service.name}.rb"

      insert_into_file file_path, before: "  end\n" do
        "    class #{name.classify} < Base; end\n"
      end
    end
  end
end
