# frozen_string_literal: true

module Ros
  class ResourceSpecGenerator < Rails::Generators::NamedBase
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
