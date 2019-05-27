# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Project
      attr_accessor :action, :args, :options

      def initialize(action, args, options)
        self.action = action
        self.args = args
        self.options = options
      end

      def execute
        template_dir = Pathname(File.dirname(__FILE__)).join('../../../assets')
        unless Dir.exists? "#{template_dir}/rails-templates"
          Dir.chdir(template_dir) { %x(git clone https://github.com/rjayroach/rails-templates.git) }
        end
        generator = ProjectGenerator.new
        generator.name = args.first
        generator.options = options
        generator.destination_root = '.'
        generator.invoke_all
      end
    end

    class ProjectGenerator < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Generate a new Ros project'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../assets/project').to_s end

      def generate
        in_root do
          %x(git clone https://github.com/rails-on-services/ros.git)
          directory('files', '.')
          empty_directory('services')
          FileUtils.cp_r('ros/devops', '.')
        end
      end

      def finish_message
        say "\nCreated Ros project at #{destination_root}"
      end

      private

      def create_ros_services
        # TODO for each ros service gem, generate a rails application in ./services that includes that gem
        # TODO figure out how the ros services are written to a new project. they should be apps that include ros service gems
      end

      def gemfile_content
        ros_gems = ''
        if options.dev
          ros_gems = <<~'EOF'
          git 'git@github.com:rails-on-services/ros.git', glob: '**/*.gemspec', branch: :master do
            gem 'ros', path: 'ros/ros'
            gem 'ros-cognito', path: 'ros/services/cognito'
            gem 'ros-comm', path: 'ros/services/comm'
            gem 'ros-core', path: 'ros/services/core'
            gem 'ros-iam', path: 'ros/services/iam'
            gem 'ros_sdk', path: 'ros/services/sdk'
          end
          EOF
        end
      end
	  end
  end
end
