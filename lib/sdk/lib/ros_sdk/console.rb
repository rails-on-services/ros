# frozen_string_literal: true

require 'config'
require 'inifile'

require 'jwt'

Config.setup do |config|
  config.use_env = true
  config.env_prefix = 'PLATFORM'
  config.env_separator = '__'
end

class Console
  attr_accessor :host, :profile, :partition

  def initialize(host = nil, profile = nil, partition = nil)
    # Get any parameters passed in and override default configuration
    self.host = host; self.profile = profile; self.partition = partition
    self.profile ||= ENV["#{self.partition&.upcase}_PROFILE"] || 'default'
    # self.host = 'https://api.ros.rails-on-services.org'
    # self.profile = '222222222_Admin_2'
    # self.partition = 'perx'
    # Set default configuration
    settings_file = Pathname(File.dirname(__FILE__)).join('../../settings.yml').to_s
    Config.load_and_set_settings(settings_file)
  end

  # Get the client configuration
  def client_config
    cc = Settings.dig(:connection, connection_type)
    return cc unless host
    uhost = URI(host)
    cc.host = uhost.hostname
    cc.port = uhost.port
    cc.scheme = uhost.scheme
    cc
  end

  def connection_type; Settings.dig(:connection, :type) end

  # Set credentials from envrionment variables
  # If credentials are not set then check for a credentials file in a known location and set credentials
  def access_key_id
    ENV["#{partition&.upcase}_ACCESS_KEY_ID"] || credentials["#{partition}_access_key_id"]
  end

  def secret_access_key
    ENV["#{partition&.upcase}_SECRET_ACCESS_KEY"] || credentials["#{partition}_secret_access_key"]
  end

  def credentials
    credentials_files.each do |file|
      next unless File.exists?(file)
      val = IniFile.load(file)[profile]
      break val if val
    end
  end

  def credentials_files
    ["#{Dir.home}/.ros/#{host&.gsub('://', '_')}", "#{Dir.home}/.#{partition}/credentials"]
  end

  # Configure the Client connection
  def configure
    Ros::Platform::Client.configure(client_config.to_h.merge(connection_type: connection_type))
    # Possible to configure service clients independently
    # Ros::IAM::Client.configure(scheme: 'http', host: 'localhost', port: 3001)
    Ros::Sdk::Credential.configure(access_key_id: access_key_id, secret_access_key: secret_access_key)
  end
end
