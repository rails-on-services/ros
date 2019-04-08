# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Env < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :project
      desc 'Generate a new Ros service'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end

      def keys; @keys ||= OpenStruct.new end

      def generate
        # TODO Thor seems to not allow attributes to be set on an instance of this class
        self.name = File.basename(Dir.pwd)
        generate_secrets
        in_root do
          File.open('.env', 'a') { |file| file.puts(env_content) }
          File.open('app.env', 'a') { |file| file.puts(app_env_content) }
          File.open('app-compose.env', 'a') { |file| file.puts(app_compose_env_content) }
        end
      end

      def finish_message
        say "\nCreated envs at #{destination_root}"
      end

      def generate_secrets
        require 'securerandom'
        keys.rails_master_key = SecureRandom.hex
        keys.secret_key_base = SecureRandom.hex(64)
        keys.jwt__encryption_key = SecureRandom.hex
        keys.platform__credential__salt = rand(10 ** 9)
        keys.platform__encryption_key = SecureRandom.hex
      end

      def env_content
        <<~HEREDOC
# .env

# Compose Variables
COMPOSE_PROJECT_NAME=#{name}

COMPOSE_FILE=docker-compose.yml:ros/docker-compose.yml

# mount host's source for dev:
# COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml:ros/docker-compose.yml

# mount host's ros source for dev:
# COMPOSE_FILE=docker-compose.yml:docker-compose-dev.yml:ros/docker-compose.yml:ros/docker-compose-dev.yml
        HEREDOC
      end

      def app_env_content
        <<~HEREDOC
# app.env
# set -a
# source app.env

# Rails
SECRET_KEY_BASE=#{keys.secret_key_base}
RAILS_MASTER_KEY=#{keys.rails_master_key}

# Service
PLATFORM__SERVICE__PARTITION_NAME=#{name}

# JWT
PLATFORM__JWT__ENCRYPTION_KEY=#{keys.jwt__encryption_key}
PLATFORM__JWT__ISS=https://iam.#{name}.net
PLATFORM__JWT__AUD=https://#{name}.net

# SDK
PLATFORM__SERVICES__CONNECTION__TYPE=host
PLATFORM__EXTERNAL_CONNECTION_TYPE=path

# IAM specific:
PLATFORM__CREDENTIAL__SALT=#{keys.platform__credential__salt}

# Comm specific:
PLATFORM__ENCRYPTION_KEY=#{keys.platform__encryption_key}
        HEREDOC
      end

      def app_compose_env_content
        <<~HEREDOC
# app-compose.env

# Rails
RAILS_DATABASE_HOST=db
        HEREDOC
      end
    end
  end
end
