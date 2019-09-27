# frozen_string_literal: true

module Ros
  class FactoryGenerator < Rails::Generators::NamedBase
    def create_files
      create_file "spec/factories/#{plural_name}.rb", <<~FILE
        # frozen_string_literal: true

        FactoryBot.define do
          factory :#{name} do
          end
        end
      FILE
    end
  end
end
