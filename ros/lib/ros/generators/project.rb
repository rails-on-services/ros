# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Project
      attr_accessor :action, :generator

      def initialize(action, args, options)
        self.action = action
        self.generator = ProjectGenerator.new
        generator.name = args.shift
        generator.destination_root = '.'
        generator.options = options
      end

      def execute
        FileUtils.mkdir_p(generator.destination_root)
        template_dir = Pathname(File.dirname(__FILE__)).join('../../../files')
        unless Dir.exists? "#{template_dir}/rails-templates"
          Dir.chdir(template_dir) { %x(git clone https://github.com/rjayroach/rails-templates.git) }
        end
        generator.invoke_all
      end
    end

    class ProjectGenerator < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Generate a new Ros project'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files/project').to_s end

      def generate
        in_root do
          # %x(git clone https://github.com/rails-on-services/ros.git)
          directory('.')
          # TODO: The devops folder of ros repo needs to be written to the project
          # %x(git clone #{base_url}rails-on-services/devops.git)
          # create_file 'services/.keep'
        end
      end

      def config_platform_content
        create_file 'config/platform.rb', <<~HEREDOC
          # frozen_string_literal: true

          module #{name.split('_').collect(&:capitalize).join}
            class Platform < Ros::Platform
              # config.compose_project_name = '#{name}'
              # config.image_repository = '#{name}'
            end
          end
        HEREDOC
      end

      # def create_ros_services
      #   # TODO for each ros service gem, generate a rails application in ./services that includes that gem
      #   # TODO figure out how the ros services are written to a new project. they should be apps that include ros service gems
      # end

      def finish_message
        say "\nCreated Ros project at #{destination_root}"
      end

      private

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
        create_file 'Gemfile' do <<~HEREDOC
          source 'https://rubygems.org'
          git_source(:github) { |repo| "https://github.com/\#{repo}.git" }

          # Gems used in the Rails application templates
          gem 'bootsnap'
          gem 'listen'
          gem 'pry'
          gem 'rails', '~> 6.0.0.beta3'
          gem 'rake'
          gem 'rspec-rails'
          gem 'rubocop'
          gem 'spring'
          #{ros_gems}
          HEREDOC
        end
      end
	  end
  end
end
