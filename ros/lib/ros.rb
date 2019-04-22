# frozen_string_literal: true
require 'dotenv'

require 'ros/version'
require 'ostruct'

module Ros
  # Copied from ActiveSupport::StringInquirer
  class StringInquirer < String
    def method_missing(method_name, *arguments)
      if method_name[-1] == '?'
        self == method_name[0..-2]
      else
        super
      end
    end
  end

  class Platform
    class << self
      def descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def config
        return @config if @config
        @config = OpenStruct.new(
          compose_files: [],
          root: Ros.root,
          env: Ros.env
          )
      end

      def configure
        yield self.config
      end
    end
  end

  class << self
    def platform
      @platform ||= Ros::Platform.descendants.first
    end

    def env
      @env ||= StringInquirer.new(ENV['ROS_ENV'] || 'development')
    end

    def root
      @root ||= (cwd = Dir.pwd
        while not cwd.eql?('/')
          break Pathname.new(cwd) if File.exists?("#{cwd}/config/platform.rb")
          cwd = File.expand_path('..', cwd)
        end)
    end

    def name
      docker_env['COMPOSE_PROJECT_NAME']
    end

    def docker_env
      require 'ros/compose'
      Ros::Compose.new.envs
    end

    def platform_env; Dotenv.parse(root.join('app.env')) end

    def service_names; services.keys.sort end

    def services
      projects.reject{ |p| projects[p].name.eql? 'core' }
    end

    def project_names; projects.keys.sort end

    def projects
      @projects ||= (Dir["#{root}/**/config/application.rb"].each_with_object({}) do |path, hash|
        key = path.to_s.gsub("#{root}/", '')
        ros = key.start_with? 'ros/services'
        key = key.split('/').shift(ros ? 3 : 2).join('/')
        engine = path.include?('dummy')
        apath = root.join(key)
        name = key.split('/').pop
        hash[key] = OpenStruct.new(engine: engine, name: name, root: apath, ros: ros)
      end)
    end
  end
end

unless Ros.root.nil?
  require Ros.root.join('config/platform')
  require Ros.root.join("config/environments/#{Ros.env}")
end
