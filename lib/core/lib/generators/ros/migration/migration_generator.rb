# frozen_string_literal: true

module Ros
  class MigrationGenerator < Rails::Generators::NamedBase
    def modify_files
      insert_into_file Dir.glob("db/migrate/*_create_#{plural_name}.rb").first, before: 'class' do
        "# frozen_string_literal: true\n\n"
      end
    end
  end
end
