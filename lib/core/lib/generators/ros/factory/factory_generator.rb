# frozen_string_literal: true

module Ros
  class FactoryGenerator < Rails::Generators::NamedBase
    def modify_files
      insert_into_file "spec/factories/#{plural_name}.rb", before: 'FactoryBot' do
        "# frozen_string_literal: true\n\n"
      end
    end
  end
end
