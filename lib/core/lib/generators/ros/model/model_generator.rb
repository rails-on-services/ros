# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ModelGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      create_file "app/models/#{name}.rb", <<~FILE
        # frozen_string_literal: true

        class Entity < #{parent_module}ApplicationRecord
        end
      FILE
    end
  end
end
