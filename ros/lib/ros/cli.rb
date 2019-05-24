# frozen_string_literal: true
# https://nandovieira.com/creating-generators-and-executables-with-thor
require 'thor'

# TODO: move new, generate and destroy to ros/generators
# NOTE: it should be possible to invoke any operation from any of rake task, cli or console

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

    # option :port, type: :string, aliases: '-p'
    # option :profiles, type: :boolean
    # option :daemon, type: :boolean, aliases: '-d'
    desc 'console', 'Start the Ros console (short-cut alias: "c")'
    option :environment, type: :string, alias: '-e'
    option :image, type: :string, alias: '-i'
    option :platform, type: :string, alias: '-p'
    option :deployment, type: :string, alias: '-d'
    map %w(c) => :console
    def console(env = 'development')
      # binding.pry
      Pry.start
    end

    desc 'list', 'List things'
    def list(what = 'platforms')
      STDOUT.puts "#{what}\n\n#{Settings.send(what).keys.join("\n")}"
    end

    # option :environment, type: :string, alias: '-e', default: 'development'
    # option :port, type: :string, aliases: '-p'
    desc 'server PROFILE', 'Start all services defined in PROFILE (short-cut alias: "s")'
    option :environment, type: :string, aliases: '-e', default: 'local'
    option :daemon, type: :boolean, aliases: '-d'
    option :noop, type: :boolean, aliases: '-n'
    map %w(s) => :server
    def server # (profile = nil)
      # options.merge!(Settings.compose.profiles.select{ |d| d.name.eql?(profile) }.first.to_h) if profile
      # require 'ros/compose'
      # Ros::Compose.new(options.merge(profile: profile)).server
      Config.load_and_set_settings('./config/platform.yml', "./config/environments/#{options.environment}.yml")
      require Ros.root.join('config/platform')
      require "ros/ops/#{Settings.infra.type}"
      type = :service
      action = :provision
      obj = Object.const_get("Ros::Ops::#{Settings.infra.type.capitalize}::#{type.to_s.capitalize}").new
      obj.options = options
      obj.send(action)
    end

    # TODO Invoke TF code to launch a server
    desc 'build SERVICE', 'Build an image for all services or a specific service'
    option :force, type: :boolean, default: false, aliases: '-f'
    option :profile, type: :string, aliases: '-p'
    def build(service = nil)
      options.merge!(Settings.compose.images.select{ |d| d.name.eql?(options.profile) }.first.to_h) if options.profile
      config = options.merge({
        service: service
      })
      require 'ros/compose'
      Ros::Compose.new(config).build
    end
    # NOTE: Perhpas could use this code:
    # def initialize(config)
    #   self.config = Thor::CoreExt::HashWithIndifferentAccess.new(
    #     port: '3000'
    #   ).merge(config)

  end
end
