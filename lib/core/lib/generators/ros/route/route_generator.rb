# frozen_string_literal: true

module Ros
  class RouteGenerator < Rails::Generators::NamedBase
    def create_files
      insert_into_file 'config/routes.rb', after: "routes.draw do\n" do
        "  jsonapi_resources :#{plural_name}\n"
      end
    end
  end
end
