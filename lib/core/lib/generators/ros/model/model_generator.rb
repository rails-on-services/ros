# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ModelGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      invoke(:model)
    end

    def gsub_created_file
      gsub_file(
        "app/models/#{name}.rb",
        'ApplicationRecord',
        "#{parent_module}ApplicationRecord"
      )
    end
  end
end
