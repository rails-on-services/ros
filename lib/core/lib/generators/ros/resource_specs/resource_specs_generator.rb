module Ros
  class ResourceSpecsGenerator < Rails::Generators::NamedBase
    def create_files
      create_file "spec/resources/#{name}_resource_spec.rb", <<~FILE
        # frozen_string_literal: true

        RSpec.describe #{name.classify}Resource, type: :resource do
          let(:#{name}) { create(:#{name}) }
        end
      FILE
    end
  end
end
