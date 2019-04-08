# frozen_string_literal: true
# https://nandovieira.com/creating-generators-and-executables-with-thor

require 'ros/version'
require 'thor'

module Ros
  class Cli < Thor
    def self.exit_on_failure?; true end

    check_unknown_options!
    class_option :verbose, type: :boolean, default: false

    desc 'version', 'Display version'
    map %w(-v --version) => :version
    def version; say "Ros #{VERSION}" end

    desc 'new PATH', 'Create a new Ros project at PATH'
    option :force, type: :boolean, default: false, aliases: '-f'
    option :dev, type: :boolean, default: false, aliases: '-d'
    # option :javascript_engine, :default => 'babeljs', :aliases => '-j'
    # option :file, :type => :array, :aliases => :files
    # option :database, :required => true
    def new(path)
      FileUtils.rm_rf(path) if Dir.exists?(path) and options.force
      raise Error, set_color("ERROR: #{path} already exists. Use -f to force", :red) if File.exist?(path)
      require_relative 'ros/generators/project.rb'
      generator = Ros::Generators::Project.new
      generator.destination_root = path
      generator.options = options
      generator.name = path
      generator.invoke_all
    end

    # Initialize all service databases: drop/create/migrate/seed
    desc 'db init', 'Create, migrate and seed databases for all services'
    option :skip, aliases: '-s'
    # TODO Test that migrations work and that skip works to skip certain services
    def db(action)
      raise Error, set_color("ERROR: invalid action #{action}. valid actions are: init", :red) unless %w(init).include? action
      return unless File.exists?('docker-compose.yml')
      Dir["./**/config/application.rb"].each do |path|
        apath = path.split('/')
        service = apath[1].eql?('ros') ? apath[2].gsub('ros-', '') : apath[1]
        next if %w(sdk core).include? service
        # binding.pry
        prefix = path.include?('dummy') ? 'app:' : ''
        %x(docker-compose exec #{service} bundle exec rails #{prefix}ros:db:reset #{prefix}ros:#{service}:db:seed)
      end
    end

    desc 'generate TYPE NAME', 'Generate a new service or environment variables'
    map %w(g) => :generate
    option :force, type: :boolean, default: false, aliases: '-f'
    def generate(artifact, name = nil)
      raise Error, set_color("ERROR: Not a Ros project", :red) unless File.exists?('app.env')
      valid_artifacts = %w(service env sdk core)
      raise Error, set_color("ERROR: invalid artifact #{artifact}. valid artifacts are: #{valid_artifacts.join(', ')}", :red) unless valid_artifacts.include? artifact
      raise Error, set_color("ERROR: must supply a name for service", :red) if artifact.eql?('service') and name.nil?
      Thing.new(artifact, name, options)
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

    # TODO Invoke TF code to launch a server
    desc 'server ACTION', 'Create or destroy a cloud server running Ros core services'
    def server(action)
      raise Error, set_color("ERROR: invalid action #{action}. valid actions are: create, destroy", :red) unless %w(create destroy).include? action
    end
  end

  class Thing
    def initialize(artifact, name, options)
      require_relative "ros/generators/#{artifact}.rb"
      generator = Object.const_get("Ros::Generators::#{artifact.capitalize}").new
      generator.destination_root = name if artifact.eql?('service')
      generator.options = options
      generator.name = name
      generator.project = File.basename(Dir.pwd)
      generator.invoke_all #(:generate)
      # generator.invoke(:finish_message)
    end
  end
end
