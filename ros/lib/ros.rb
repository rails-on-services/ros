# frozen_string_literal: true

require 'ros/version'
require 'pry'
require 'config'

Config.setup do |config|
  config.use_env = true
  config.env_prefix = 'PLATFORM'
  config.env_separator = '__'
end

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

  class << self
    def ops_action(type, action, options = Config::Options.new)
      provider, infra_type = Settings.meta.components.provider.split('/')
      require "ros/ops/#{infra_type}"
      obj = Object.const_get("Ros::Ops::#{infra_type.capitalize}::#{type.to_s.capitalize}").new(options)
      obj.send(action)
    end

    # load deployments/env and environments/env
    # If the environment has a '-' in it and an environment is defined before the '-' then use it as a base
    def load_env(env = nil)
      Ros.env = env if env
      envs = []
      envs.append(Ros.env.split('-').first) if Ros.env&.index('-')
      envs.append(Ros.env)
      files = ['./config/deployment.yml']
      %w(deployments environments).each do |type|
        envs.each do |env|
          asset = "./config/#{type}/#{env}.yml"
          files.append(asset) if File.exists?(asset)
        end
      end
      Config.load_and_set_settings(files)
    end

    # Underscored representation of a Config hash
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

    # def platform; @platform ||= Ros::Platform.descendants.first end
    def env; @env ||= StringInquirer.new(ENV['ROS_ENV'] || default_env) end
    def env=(env); @env = StringInquirer.new(env) end
    def default_env; @default_env ||= 'local' end

    def root
      @root ||= (cwd = Dir.pwd
        while not cwd.eql?('/')
          break Pathname.new(cwd) if File.exists?("#{cwd}/config/deployment.yml")
          cwd = File.expand_path('..', cwd)
        end)
    end

    def tf_root; root.join('devops/terraform') end
    def ansible_root; root.join('devops/ansible') end
    def helm_root; root.join('devops/helm') end
    def k8s_root; root.join('devops/k8s') end

    def config_dir; 'config' end
    def environments_dir; "#{config_dir}/environments" end
    def deployments_dir; "#{config_dir}/deployments" end

    def ros_root; root.join('ros') end

    def has_ros?; not is_ros? and Dir.exists?(ros_root) end

    # TODO: This is a hack in order to differentiate for purpose of templating files
    def is_ros?
      Settings.devops.registry.eql?('railsonservices') and Settings.platform.partition_name.start_with?('ros')
    end
  end
end

Ros.load_env unless Ros.root.nil?
