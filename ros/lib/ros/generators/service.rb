# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Service < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Generate a new Ros service'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end

      # attr_accessor :project, :name, :args, :options

      # def initialize(args, options)
      #   self.name = args.shift
      #   self.args = args
      #   self.options = options
      #   self.project = File.basename(Dir.pwd)
      # end

      def generate
        # %x(rails plugin new --full --api --dummy-path=spec/dummy -S -J -C -T-M ros-dump)
        %x(rails new --api -S -J -C -T -M -m rails-templates/6-api.rb #{name})
      end

      def finish_message
        say "\nCreated Ros service at #{destination_root}"
      end

      def execute
        # File.open('init', 'a') { |file| file.puts("docker-compose exec #{name} bundle exec rails ros:db:reset db:seed") }
        File.open('docker-compose.yml', 'a') { |file| file.puts(compose_content) }
        File.open('docker-compose-dev.yml', 'a') { |file| file.puts(compose_dev_content) }
        File.open('nginx-services.conf', 'a') { |file| file.puts(nginx_content) }
      end

      # TODO: Project name goes into .env and then just reference the variable name in this compose content
      def compose_content
        <<~HEREDOC
  #{name}:
    image:
      "#{project}/#{name}:${rails_env:-development}-${image_tag:-undefined}"
    build:
      context: .
      args:
        bundle_string: "${bundle_string:---with=development test}"
        rails_env: "${rails_env:-development}"
        os_packages: "${os_packages:-libpq5 git sudo vim less tcpdump net-tools iputils-ping}"
        project: #{name}
        PUID: "${puid:-1000}"
        PGID: "${pgid:-1000}"
    env_file:
      - app.env
      - app-compose.env
    depends_on:
      - wait
    command: ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] # don't start the server
    ports:
      - "3000"
        HEREDOC
      end

      def compose_dev_content
        <<~HEREDOC
  #{name}:
    # ports:
      # - '1234:1234'
      # - '9394:9394'
    command: ["tail", "-F", "log/development.log"] # don't start the server
    volumes:
      - ./#{name}:/home/rails/app
      - ./gems/ros-core:/home/rails/gems/ros-core
      - ./gems/ros_sdk:/home/rails/gems/ros_sdk
      - ./#{project}-core:/home/rails/#{project}-core
      - ./#{project}_sdk:/home/rails/#{project}_sdk
        HEREDOC
      end


      def nginx_content
        <<~HEREDOC
        location /#{name}/ {
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://#{name}:3000/;
        }
        HEREDOC
      end

    end
  end
end
