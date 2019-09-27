# frozen_string_literal: true

require_relative '../generators.rb'
require_relative '../generators_helper.rb'

module Ros
  class EndpointGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    source_root File.expand_path('templates', __dir__)

    def create_files
      generate_resource
      generate_request_spec
      generate_resource_spec
      generate_policy
      generate_policy_spec
      generate_api_doc
      generate_model
      generate_model_specs
      generate_factory
      generate_and_modify_controller
    end

    private

    def generate_request_spec
      Ros::RequestSpecGenerator.new([name]).invoke_all
    end

    def generate_resource
      Ros::ResourceGenerator.new([name]).invoke_all
    end

    def generate_resource_spec
      Ros::ResourceSpecGenerator.new([name]).invoke_all
    end

    def generate_policy
      Ros::PolicyGenerator.new([name]).invoke_all
    end

    def generate_policy_spec
      Ros::PolicySpecGenerator.new([name]).invoke_all
    end

    def generate_api_doc
      Ros::ApiDocGenerator.new([name]).invoke_all
    end

    def generate_route
      Ros::RouteGenerator.new([name]).invoke_all
    end

    def generate_and_modify_controller
      invoke(:controller)
      gsub_file(
        "app/controllers/#{plural_name}_controller.rb",
        'ApplicationController',
        "#{parent_module}ApplicationController"
      )
    end

    def generate_model
      Ros::ModelGenerator.new([name]).invoke_all
    end

    def generate_model_specs
      Ros::ModelSpecGenerator.new([name]).invoke_all
    end

    def generate_factory
      Ros::FactoryGenerator.new([name]).invoke_all
    end
  end
end
