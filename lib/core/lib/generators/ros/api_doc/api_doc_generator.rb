# frozen_string_literal: true

module Ros
  class ApiDocGenerator < Rails::Generators::NamedBase
    def create_files
      create_file "doc/resources/#{name}_resource_doc.rb", <<-FILE
        # frozen_string_literal: true

        class #{name.classify}ResourceDoc < ApplicationDoc
          route_base '#{plural_name}'

          api :index, 'All #{plural_name.capitalize}'
          api :show, 'Single #{name.capitalize}'
          api :create, 'Create #{name.capitalize}'
          api :update, 'Update #{name.capitalize}'
        end
      FILE
    end
  end
end
