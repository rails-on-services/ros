# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Env
      attr_accessor :action, :generator

      def initialize(action, args, options)
        self.action = action
        self.generator = EnvGenerator.new
        generator.name = args.shift
        generator.destination_root = 'config/settings'
        host = args.shift || 'http://localhost:3000'
        generator.options = options.merge(uri: URI(host))
      end

      def execute
        if action.eql? :new
          %w(console local development production).each do |env|
            xgenerator = EnvGenerator.new
        xgenerator.destination_root = 'config/settings'
        host = 'http://localhost:3000'
        xgenerator.options = generator.options.merge(uri: URI(host))
            xgenerator.name = env
            xgenerator.invoke_all
          end
          # TODO: implement
          # NOTE: current format_envs is a method in deployment.rb; maybe move to Ros
          # binding.pry
          Config.load_and_set_settings('config/settings/console.yml')
          content = Ros.format_envs('', Settings).join("\n")
          # binding.pry
          File.write('config/console.env', content)
        else
          generator.invoke_all
        end
      end

      # def x_execute
      #   generator.destination_root = artifact.eql?('service') ? "services/#{name}" : "services/#{name}#{artifact.eql?('sdk') ? '_' : '-'}#{artifact}"
      #   FileUtils.rm_rf(generator.destination_root) if Dir.exists?(generator.destination_root) and options.force
      #   generator.options = options
      #   generator.name = name
      #   generator.project = File.basename(Dir.pwd)
      #   generator.invoke_all
      # end
    end

    class EnvGenerator < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Initialize a platform environment'

      def keys; @keys ||= Config::Options.new end

      def generate_secrets
        require 'securerandom'
        keys.rails_master_key = SecureRandom.hex
        keys.secret_key_base = SecureRandom.hex(64)
        keys.platform = Config::Options.new
        keys.platform.jwt = Config::Options.new
        keys.platform.jwt.encryption_key = SecureRandom.hex
        keys.platform.credential = Config::Options.new
        keys.platform.credential.salt = rand(10 ** 9)
        keys.platform.encryption_key = SecureRandom.hex
      end

      def platform_env
        create_file "#{name}.yml", <<~HEREDOC
          # ENVs read by the docker compose files to set common values across all services
          # If the direnv package is installed these values will automatically be set as shell variables upon entering the project directory
          # Otherwise, to set these values manually from the project root directory in the shell do this:
          # $ set -a
          # $ source config/env

          # Rails
          secret_key_base: #{keys.secret_key_base}
          rails_master_key: #{keys.rails_master_key}

          # Uncomment to set to a remote host
          # rails_database_host: localhost

          # Service
          platform:
            partition_name: #{name}

          # JWT
            jwt:
              encryption_key: #{keys.platform.jwt.encryption_key}
              iss: #{options.uri.scheme}://iam.#{options.uri.to_s.split('//').last}
              aud: #{options.uri}

          # Hosts to which these services respond to
            hosts: #{options.uri.host}

          # Postman workspace to which API documentation updates are written
            postman:
              workspace: #{options.uri.host}
              api_key:

            api_docs:
              server:
                host: #{options.uri}

          # SDK
            connection:
              type: host
            external_connection_type: path

          # Services
          services:
            iam:
              environment:
                platform:
                  credential:
                    salt: #{keys.platform.credential.salt}

            comm:
              environment:
                platform:
                  encryption_key: #{keys.platform.encryption_key}
        HEREDOC
      end

      def finish_message
        say "\nCreated envs at #{destination_root}"
      end
    end
  end
end
