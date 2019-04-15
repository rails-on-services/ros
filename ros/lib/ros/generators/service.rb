# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Service < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :project
      desc 'Generate a new Ros service'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end

      def generate
        template_file = "#{self.class.source_root}/rails-templates/6-api.rb"
        rails_options = '--api -S -J -C -T -M'
        system "rails new #{rails_options} -m #{template_file} #{name}"
      end

      # TODO: Project name goes into .env and then just reference the variable name in this compose content
      def compose_content
        append_to_file '../docker-compose.yml' do <<-HEREDOC
  #{name}:
    image:
      "${image_repository}/#{name}:${rails_env:-development}-${image_tag:-undefined}"
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
      - docker-compose.env
    depends_on:
      - wait
    command: ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] # don't start the server
    ports:
      - "3000"
        HEREDOC
        end
      end

      def compose_dev_content
        append_to_file '../docker-compose-dev.yml' do <<-HEREDOC
  #{name}:
    # ports:
      # - '1234:1234'
      # - '9394:9394'
    command: ["tail", "-F", "log/development.log"] # don't start the server
    volumes:
      - ./#{name}:/home/rails/app
      - ./ros/core:/home/rails/ros/core
      - ./ros/sdk:/home/rails/ros/sdk
      - ./core:/home/rails/core
      - ./sdk:/home/rails/sdk
        HEREDOC
        end
      end


      def nginx_content
        append_to_file '../containers/nginx/services.conf' do <<~HEREDOC
        location /#{name}/ {
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://#{name}:3000/;
        }
        HEREDOC
        end
      end

      def sdk_content
        append_to_file "../sdk/lib/#{project}_sdk/models.rb" do <<~HEREDOC
          require '#{project}_sdk/models/#{name}.rb'
          HEREDOC
        end
        create_file "../sdk/lib/#{project}_sdk/models/#{name}.rb" do <<~HEREDOC
          # frozen_string_literal: true

          module #{project}
            module #{name}
              class Client < Ros::Platform::Client; end
              class Base < Ros::Sdk::Base; end

              class Tenant < Base; end
            end
          end
          HEREDOC
        end
      end

      def finish_message
        say "\nCreated Ros service at #{destination_root}"
      end
    end
  end
end
