# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Env < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Initialize a Ros project environment'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files/project').to_s end

      def keys; @keys ||= OpenStruct.new end

      def generate
        in_root do
          directory('.')
          create_file 'services/.keep'
          # TODO write out variables to TF code's terraform.tfvars in devops
        end
      end

      def version_content
        create_file 'VERSION', <<~HEREDOC
          0.1.0
        HEREDOC
      end

      def generate_secrets
        require 'securerandom'
        keys.rails_master_key = SecureRandom.hex
        keys.secret_key_base = SecureRandom.hex(64)
        keys.platform__jwt__encryption_key = SecureRandom.hex
        keys.platform__credential__salt = rand(10 ** 9)
        keys.platform__encryption_key = SecureRandom.hex
      end

      def config_platform_content
        create_file 'config/platform.rb', <<~HEREDOC
          # frozen_string_literal: true

          module #{name.split('_').collect(&:capitalize).join}
            class Platform < Ros::Platform
              config.compose_project_name = '#{name}'
              config.image_repository = '#{name}'
            end
          end
        HEREDOC
      end

      def config_platform_content
        append_to_file "#{Ros.root}/compose/base.yml", <<-HEREDOC
      - "${ROS_DIR}/compose/containers/nginx/services.conf:/etc/nginx/conf.d/services/ros.conf"
        HEREDOC
      end if Ros.has_ros?

      def app_env_content
        create_file 'config/env', <<~HEREDOC
          # ENVs read by the docker compose files to set common values across all services
          # If the direnv package is installed these values will automatically be set as shell variables upon entering the project directory
          # Otherwise, to set these values manually from the project root directory in the shell do this:
          # $ set -a
          # $ source config/env

          # Rails
          SECRET_KEY_BASE=#{keys.secret_key_base}
          RAILS_MASTER_KEY=#{keys.rails_master_key}

          # Uncomment to set to a remote host
          # RAILS_DATABASE_HOST=localhost

          # Service
          PLATFORM__PARTITION_NAME=#{name}

          # JWT
          PLATFORM__JWT__ENCRYPTION_KEY=#{keys.platform__jwt__encryption_key}
          PLATFORM__JWT__ISS=#{options.uri.scheme}://iam.#{options.uri.to_s.split('//').last}
          PLATFORM__JWT__AUD=#{options.uri}

          # Hosts to which these services respond to
          PLATFORM__HOSTS=#{options.uri.host}

          # Postman workspace to which API documentation updates are written
          PLATFORM__POSTMAN__WORKSPACE=#{options.uri.host}
          PLATFORM__POSTMAN__API_KEY=

          PLATFORM__API_DOCS__SERVER__HOST=#{options.uri}

          # SDK
          PLATFORM__CONNECTION__TYPE=host
          PLATFORM__EXTERNAL_CONNECTION_TYPE=path

          # IAM specific:
          PLATFORM__CREDENTIAL__SALT=#{keys.platform__credential__salt}

          # Comm specific:
          PLATFORM__ENCRYPTION_KEY=#{keys.platform__encryption_key}
        HEREDOC
      end

      def compose_env_content
        create_file 'compose/env', <<~HEREDOC
          RAILS_DATABASE_HOST=db
        HEREDOC
      end

      def rakefile_content
        create_file 'Rakefile', <<~HEREDOC
          load 'ros/tasks/Rakefile'
        HEREDOC
      end

      def finish_message
        say "\nCreated envs at #{destination_root}"
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
