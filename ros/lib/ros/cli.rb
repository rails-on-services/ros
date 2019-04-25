# frozen_string_literal: true
# https://nandovieira.com/creating-generators-and-executables-with-thor
require 'thor'
require 'pry'

module Ros
  class Cli < Thor
    def self.exit_on_failure?; true end

    check_unknown_options!
    class_option :verbose, type: :boolean, default: false

    desc 'version', 'Display version'
    map %w(-v --version) => :version
    def version; say "Ros #{VERSION}" end

    desc 'new', "Create a new Ros platform project. \"ros new my_project\" creates a\n" \
      'new project called MyProject in "./my_project"'
    option :force, type: :boolean, default: false, aliases: '-f'
    option :dev, type: :boolean, default: false, aliases: '-d' #, required: true
    def new(name, host = nil)
      FileUtils.rm_rf(name) if Dir.exists?(name) and options.force
      require 'pry'
      raise Error, set_color("ERROR: #{name} already exists. Use -f to force", :red) if File.exist?(name)
      require_relative 'generators/project.rb'
      generator = Ros::Generators::Project.new
      generator.destination_root = name
      generator.options = options
      generator.name = name
      FileUtils.mkdir_p(generator.destination_root)
      Dir.chdir(name) { init(nil, host) }
      generator.invoke_all
      Dir.chdir(name) { generate('sdk', name) }
      Dir.chdir(name) { generate('core', name) }
    end

    desc 'generate TYPE NAME', 'Generate a new service, sdk or core gem'
    map %w(g) => :generate
    option :force, type: :boolean, default: false, aliases: '-f'
    def generate(artifact, name = nil)
      raise Error, set_color("ERROR: Not a Ros project", :red) unless File.exists?('config/env')
      valid_artifacts = %w(service sdk core)
      raise Error, set_color("ERROR: invalid artifact #{artifact}. valid artifacts are: #{valid_artifacts.join(', ')}", :red) unless valid_artifacts.include? artifact
      raise Error, set_color("ERROR: must supply a name for service", :red) if artifact.eql?('service') and name.nil?
      require_relative "generators/#{artifact}.rb"
      generator = Object.const_get("Ros::Generators::#{artifact.capitalize}").new
      generator.destination_root = artifact.eql?('service') ? "services/#{name}" : "services/#{name}#{artifact.eql?('sdk') ? '_' : '-'}#{artifact}"
      FileUtils.rm_rf(generator.destination_root) if Dir.exists?(generator.destination_root) and options.force
      generator.options = options
      generator.name = name
      generator.project = File.basename(Dir.pwd)
      generator.invoke_all
    end

    desc 'destroy TYPE NAME', 'Destroy a service, sdk or core gem'
    map %w(d) => :destroy
    def destroy(artifact, name = nil)
      valid_artifacts = %w(service)
      raise Error, set_color("ERROR: invalid artifact #{artifact}. valid artifacts are: #{valid_artifacts.join(', ')}", :red) unless valid_artifacts.include? artifact
      raise Error, set_color("ERROR: must supply a name for service", :red) if artifact.eql?('service') and name.nil?
      require_relative "generators/#{artifact}.rb"
      generator = Object.const_get("Ros::Generators::#{artifact.capitalize}").new
      generator.destination_root = artifact.eql?('service') ? "services/#{name}" : "services/#{name}#{artifact.eql?('sdk') ? '_' : '-'}#{artifact}"
      generator.options = options
      generator.name = name
      generator.project = File.basename(Dir.pwd)
      generator.behavior = :revoke
      generator.invoke_all
    end

    desc 'init', 'Initialize the project with default settings'
    def init(name = nil, host = nil)
      name ||= File.basename(Dir.pwd)
      host ||= 'http://localhost:3000'
      require_relative 'generators/env.rb'
      generator = Ros::Generators::Env.new
      generator.options = options.merge(uri: URI(host))
      generator.name = name
      generator.invoke_all
    end

    # TODO Handle show and edit as well
    desc 'lpass ACTION', 'Transfer the contents of app.env to/from a Lastpass account'
    option :username, aliases: '-u'
    def lpass(action)
      raise Error, set_color("ERROR: invalid action #{action}. valid actions are: add, show, edit", :red) unless %w(add show edit).include? action
      raise Error, set_color("ERROR: Not a Ros project", :red) unless File.exists?('app.env')
      lpass_name = "#{File.basename(Dir.pwd)}/development"
      %x(lpass login #{options.username}) if options.username
      %x(lpass add --non-interactive --notes #{lpass_name} < app.env)
    end

    desc 'server', 'Start all services defined in the ./compose directory (short-cut alias: "s")'
    option :port, type: :string, default: '3000', aliases: '-p'
    option :daemon, type: :boolean, aliases: '-d'
    map %w(s) => :server
    def server(env = 'development')
      require 'pry'
      require 'ros/compose'
      Ros::Compose.user_envs = {
        'NGINX_HOST_PORT' => options.port,
        'RAILS_ENV' => env
      }
      Ros::Compose.write_env_file
      compose_options = options.daemon ? '-d' : ''
      system("docker-compose up #{compose_options}")
    end

    desc 'console', 'Start the Ros console (short-cut alias: "c")'
    map %w(c) => :console
    def console(env = 'development')
      require 'pry'
      Pry.start
    end

    # TODO Invoke TF code to launch a server
    desc 'infra ACTION', 'Create or destroy a cloud server running Ros core services'
    def infra(action)
      raise Error, set_color("ERROR: invalid action #{action}. valid actions are: create, destroy", :red) unless %w(create destroy).include? action
    end
  end
end
