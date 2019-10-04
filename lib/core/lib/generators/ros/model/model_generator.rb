# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ModelGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      invoke(:model)
    end

    def modify_files
      insert_into_file "app/models/#{name}.rb", after: "ApplicationRecord\n" do
        "  # NOTE: organize your model code in the following sequence\n"\
        "  # includes/extends, constants, gems related, serialized attributes, associations, attr_accessible\n" \
        "  # scopes, class methods, validations, instance methods, other methods, private methods\n"
      end
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
