# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Service < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :project
      desc 'Generate a new Ros service'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end
      def one_service?
        services = Dir['services/*'] - ['services/core', 'services/sdk']
        services.size.eql?(1) and services.first.eql? "services/#{name}"
      end

      def generate
        return unless self.behavior.eql? :invoke
        template_file = "#{self.class.source_root}/rails-templates/6-api.rb"
        rails_options = '--api -S -J -C -T -M'
        exec_system = "rails new #{rails_options} -m #{template_file} #{name}"
        puts exec_system
        # FileUtils.mkdir_p destination_root
        Dir.chdir('services') { system exec_system }
      end

      def compose_services_header_content
        return unless one_service?
        create_file "#{Ros.root}/compose/services.yml", <<~HEREDOC
          version: '3'
          services:
        HEREDOC
      end

      # TODO: Project name goes into .env and then just reference the variable name in this compose content
      def compose_services_content
        return unless File.exists? "#{Ros.root}/compose/services.yml"
        append_to_file "#{Ros.root}/compose/services.yml", <<-HEREDOC
  #{name}:
    image:
      "${IMAGE_REPOSITORY}/#{name}:${RAILS_ENV:-development}-${IMAGE_TAG:-undefined}"
    build:
      context: ..
      args:
        bundle_string: "${BUNDLE_STRING:---with=development test}"
        rails_env: "${RAILS_ENV:-development}"
        os_packages: "${OS_PACKAGES:-libpq5 git sudo vim less tcpdump net-tools iputils-ping}"
        project: #{name}
        PUID: "${PUID:-1000}"
        PGID: "${PGID:-1000}"
    env_file:
      - ../config/env
      - ./env
    depends_on:
      - wait
    command: ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] # don't start the server
    ports:
      - "3000"
        HEREDOC
      end

      def compose_mounts_header_content
        return unless one_service?
        create_file "#{Ros.root}/compose/mounts.yml", <<~HEREDOC
          # mount project source directories so changes to source are immediately reflected in the services
          version: '3'
          services:
        HEREDOC
      end

      def compose_mounts_content
        return unless File.exists? "#{Ros.root}/compose/mounts.yml"
        append_to_file "#{Ros.root}/compose/mounts.yml", <<-HEREDOC
  #{name}:
    # ports:
      # - '1234:1234'
      # - '9394:9394'
    command: ["tail", "-F", "log/development.log"] # don't start the server
    volumes:
      - ../services/#{name}:/home/rails/app
      - ../services/core:/home/rails/core
      - ../services/sdk:/home/rails/sdk
        HEREDOC
      end

      def compose_mounts_content_ros
        append_to_file "#{Ros.root}/compose/mounts.yml", <<-HEREDOC
      - ../ros/services/core:/home/ros/services/core
      - ../ros/services/sdk:/home/ros/services/sdk
        HEREDOC
      end if Dir.exists?(Ros.platform.config.ros_root.to_s)

      def nginx_file
        return unless one_service?
        create_file "#{Ros.root}/compose/containers/nginx/services.conf"
      end

      def nginx_content
        return unless File.exists? "#{Ros.root}/compose/containers/nginx/services.conf"
        append_to_file "#{Ros.root}/compose/containers/nginx/services.conf", <<~HEREDOC
          location /#{name}/ {
            proxy_set_header X-Forwarded-Host $http_host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_pass http://#{name}:3000/;
          }
        HEREDOC
      end

      def compose_nginx_file
        return unless one_service?
        create_file "#{Ros.root}/compose/nginx.yml", <<~HEREDOC
          version: '3'
          services:
            nginx:
              depends_on:
        HEREDOC
      end

      def compose_nginx_content
        return unless File.exists? "#{Ros.root}/compose/nginx.yml"
        append_to_file "#{Ros.root}/compose/nginx.yml", <<-HEREDOC
      - #{name}
        HEREDOC
      end

      def sdk_content
        append_file "../sdk/lib/#{project}_sdk/models.rb", <<~HEREDOC
          require '#{project}_sdk/models/#{name}.rb'
        HEREDOC

        create_file "../sdk/lib/#{project}_sdk/models/#{name}.rb", <<~HEREDOC
          # frozen_string_literal: true

          module #{project.split('_').collect(&:capitalize).join}
            module #{name.split('_').collect(&:capitalize).join}
              class Client < Ros::Platform::Client; end
              class Base < Ros::Sdk::Base; end

              class Tenant < Base; end
            end
          end
        HEREDOC
      end

      def finish_message
        FileUtils.rm_rf(destination_root) if self.behavior.eql? :revoke
        action = self.behavior.eql?(:invoke) ? 'Created' : 'Destroyed'
        say "\n#{action} service at #{destination_root}"
      end
    end
  end
end
