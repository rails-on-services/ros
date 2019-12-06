# frozen_string_literal: true

require_relative '../generators.rb'
require_relative '../generators_helper.rb'

module Ros
  class EndpointGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def generate_request_spec
      Ros::RequestSpecGenerator.new([name]).invoke_all
    end

    def generate_resource
      Ros::ResourceGenerator.new([name], @args).invoke_all
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

    def generate_sdk_endpoint
      Ros::SdkEndpointGenerator.new([name]).invoke_all
    end

    def generate_controller
      Ros::ControllerGenerator.new([name]).invoke_all
    end

    def generate_model
      Ros::ModelGenerator.new(ARGV).invoke_all
    end

    def generate_model_specs
      Ros::ModelSpecGenerator.new([name]).invoke_all
    end

    def generate_migration
      Ros::MigrationGenerator.new([name]).invoke_all
    end

    def generate_factory
      Ros::FactoryGenerator.new([name]).invoke_all
    end
  end
end
