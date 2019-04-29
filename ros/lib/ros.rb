# frozen_string_literal: true
require 'pry'
require 'config'

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

    def tf_root; root.join('devops/terraform') end
    def ansible_root; root.join('devops/ansible') end
    def helm_root; root.join('devops/helm') end

    def ros_root; root.join('ros') end

    def has_ros?; not is_ros? and Dir.exists?(ros_root) end

    # TODO: This is a hack in order to differentiate for purpose of templating files
    def is_ros?
      platform.config.compose.image_repository.eql?('rails-on-services') and platform.config.compose.project_name.eql?('ros')
    end

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
  Config.load_and_set_settings('./config/platform.yml', "./config/environments/#{Ros.env}.yml")
  require Ros.root.join('config/platform')
end
