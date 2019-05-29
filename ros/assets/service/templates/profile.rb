# frozen_string_literal: true

class Profile
  attr_accessor :name, :platform_name, :service_name, :module_name, :module_string
  attr_accessor :app_dir, :initializer_file, :routes_file
  attr_accessor :ros_path, :ros_lib_path
  attr_accessor :is_engine, :is_ros

  def initialize(name, generator, options)
    self.name = name
    self.platform_name = generator.destination_root.split('/').pop(3).first
    self.service_name = name.gsub('ros-', '')
    self.module_name = service_name.classify
    #
    self.is_ros = platform_name.eql?('ros')
    self.is_engine = (options.full or options.mountable)
    # 
    self.module_string = is_engine? ? module_name : 'Ros'
    self.app_dir = is_engine? ? "#{options.dummy_path}/" : '.'
    self.initializer_file = is_engine? ? "lib/#{name.gsub('-', '/')}/engine.rb" : 'config/application.rb'
    self.routes_file = "#{app_dir}/config/routes.rb"
    # TODO: this should be calculated if this is an engine or not
    self.ros_path = '../../ros'
    self.ros_lib_path = "#{ros_path}/services"
  end
  def is_engine?; is_engine end
  def is_ros?; is_ros end
end
