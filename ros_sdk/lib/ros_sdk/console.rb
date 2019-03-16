# frozen_string_literal: true

require 'config'
require 'inifile'

require 'jwt'

Config.setup do |config|
  config.use_env = true
  config.env_prefix = 'PLATFORM'
  config.env_separator = '__'
end

# For local development w/out docker you probably want to run services on different ports:
# export PLATFORM__SERVICES__CONNECTION__TYPE=port
# For local development w docker-compse and nginx probalby want to run with paths:
# export PLATFORM__SERVICES__CONNECTION__TYPE=path
settings_file = Pathname(File.dirname(__FILE__)).join('../../settings.yml').to_s
Config.load_and_set_settings(settings_file)
connection_type = Settings.dig(:services, :connection, :type)
client_config = Settings.dig(:services, :connection, connection_type).to_h
Ros::Platform::Client.configure(client_config.merge(connection_type: connection_type))
# Ros::IAM::Client.configure(scheme: 'http', host: 'localhost', port: 3001)
Ros::Sdk::Credential.configure
