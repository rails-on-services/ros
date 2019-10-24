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

    def generate_controller
      invoke(:controller, [plural_name])
      insert_into_file "app/controllers/#{plural_name}_controller.rb", before: 'class' do
        "# frozen_string_literal: true\n\n"
      end

      gsub_file(
        "app/controllers/#{plural_name}_controller.rb",
        'ApplicationController',
        "#{parent_module}ApplicationController"
      )
    end

    def generate_model
      Ros::ModelGenerator.new(ARGV).invoke_all
    end

    def generate_model_specs
      Ros::ModelSpecGenerator.new([name]).invoke_all
    end
  end
end
