require_relative '../generators.rb'

class RequestSpecsGenerator < Rails::Generators::NamedBase
  include Generators

  def create_files
    create_request_specs
  end
end
