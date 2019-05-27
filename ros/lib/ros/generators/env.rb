# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Env
      attr_accessor :action, :args, :options

      def initialize(action, args, options)
        args.push('http://localhost:3000') if args.size == 1
        envs = action.eql?(:new) ? %w(console local development production) : [args.first]
        args.push(envs)
        self.action = action
        self.args = args
        self.options = options
      end

      def execute
        name, host, envs = args
        envs.each do |env|
          generator = EnvGenerator.new
          generator.name = name
          generator.env = env
          generator.options = options.merge(uri: URI(host))
          generator.destination_root = 'config/environments'
          generator.invoke_all
        end
        if action.eql? :new
          Config.load_and_set_settings('config/environments/console.yml')
          content = Ros.format_envs('', Settings).join("\n")
          File.write('config/console.env', console_content)
          File.append('config/console.env', content)
          FileUtils.rm('config/environments/console.yml')
        end
      end

      def console_content
        "# ENVs read by the docker compose files to set common values across all services\n" \
        "# If the direnv package is installed these values will automatically be set as shell variables upon entering the project directory\n" \
        "# Otherwise, to set these values manually from the project root directory in the shell do this:\n" \
        "# $ set -a\n" \
        "# $ source config/console.env\n" \
        "# $ set +a\n"
      end
    end

    class EnvGenerator < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :env
      desc 'Initialize a platform environment'
      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../assets/project').to_s end

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
        keys.platform.partition_name = name
        template 'templates/environments.yml.erb', "#{env}.yml"
      end

      def finish_message
        say "\nCreated envs at #{destination_root}"
      end
    end
  end
end
