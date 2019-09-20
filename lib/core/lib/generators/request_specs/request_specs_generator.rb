require_relative '../specs_generator.rb'

class RequestSpecsGenerator < Rails::Generators::NamedBase
  include SpecsGenerator

  def create_files
    create_request_specs
  end
end
