# frozen_string_literal: true
require 'pry'
require 'config'
Config.setup do |config|
  config.use_env = true
  config.env_prefix = 'PLATFORM'
  config.env_separator = '__'
end

require 'ros/version'


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

      def config; @config ||= Settings end

      def configure
        yield self.config
        self
      end
    end
  end

  class << self
    def ops_action(type, action, options = Config::Options.new)
      provider, infra_type = Settings.meta.components.provider.split('/')
      require "ros/ops/#{infra_type}"
      obj = Object.const_get("Ros::Ops::#{infra_type.capitalize}::#{type.to_s.capitalize}").new(options)
      # require "ros/ops/#{Settings.infra.type}"
      # obj = Object.const_get("Ros::Ops::#{Settings.infra.type.capitalize}::#{type.to_s.capitalize}").new(options)
      obj.send(action)
    end

    # TODO: remove the '-' thing and use inherit from
    def load_env(env = nil)
      files = ['./config/platform.yml']
      if env&.index('-')
        base_file = "./config/environments/#{env.split('-').first}.yml"
        files.append(base_file) if File.exists?(base_file)
      end
      Ros.env = env if env
      files.append("./config/environments/#{Ros.env}.yml")
      Config.load_and_set_settings(files)
      require Ros.root.join('config/platform')
    end

    def format_envs(key, value, ary = [])
      if value.is_a?(Config::Options)
        value.each_pair do |skey, value|
          format_envs("#{key}#{key.empty? ? '' : '__'}#{skey}", value, ary)
        end
      else
        ary.append("#{key.upcase}=#{value}")
      end
      ary
    end

    def platform; @platform ||= Ros::Platform.descendants.first end
    def env; @env ||= StringInquirer.new(ENV['ROS_ENV'] || default_env) end
    def env=(env); @env = StringInquirer.new(env) end
    def default_env; @default_env ||= 'local' end

    def root
      @root ||= (cwd = Dir.pwd
        while not cwd.eql?('/')
          break Pathname.new(cwd) if File.exists?("#{cwd}/config/platform.rb")
          cwd = File.expand_path('..', cwd)
        end)
    end

    def tf_root; root.join('devops/terraform') end
    def ansible_root; root.join('devops/ansible') end
    def helm_root; root.join('devops/helm') end
    def k8s_root; root.join('devops/k8s') end

    def ros_root; root.join('ros') end

    def has_ros?; not is_ros? and Dir.exists?(ros_root) end

    # TODO: This is a hack in order to differentiate for purpose of templating files
    def is_ros?
      Settings.devops.registry.eql?('railsonservices') and Settings.platform.environment.partition_name.start_with?('ros')
    end

    # def service_names; services.keys.sort end

    # def services
    #   projects.reject{ |p| projects[p].name.eql? 'core' }
    # end

    # def project_names; projects.keys.sort end

    # def projects
    #   @projects ||= (Dir["#{root}/**/config/application.rb"].each_with_object({}) do |path, hash|
    #     key = path.to_s.gsub("#{root}/", '')
    #     ros = key.start_with? 'ros/services'
    #     key = key.split('/').shift(ros ? 3 : 2).join('/')
    #     engine = path.include?('dummy')
    #     apath = root.join(key)
    #     name = key.split('/').pop
    #     hash[key] = OpenStruct.new(engine: engine, name: name, root: apath, ros: ros)
    #   end)
    # end
  end
end

Ros.load_env unless Ros.root.nil?
