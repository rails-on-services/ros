# frozen_string_literal: true
require 'globalid'

module Ros
  module Sdk
    class << self
      attr_accessor :configured_services

      def service_endpoints
        configured_services.each_with_object({}) do |service, hash|
          hash[service[0]] = service[1]::Base.site
        end
      rescue
        raise ClientConfigurationError
      end
    end

    class ClientConfigurationError < StandardError; end

    class Base < JsonApiClient::Resource
      attr_accessor :gid

      def to_gid
        @gid ||= GlobalID.new("gid://internal/#{self.class.name}/#{id}")
      end
    end

    class Credential
      class << self
        attr_accessor :profile, :access_key_id, :secret_access_key, :partition, :region, :authorization

        def configure(profile: (ENV["#{partition.upcase}_PROFILE"] || 'default'),
                      access_key_id: ENV["#{partition.upcase}_ACCESS_KEY_ID"],
                      secret_access_key: ENV["#{partition.upcase}_SECRET_ACCESS_KEY"])
          return if self.access_key_id = access_key_id and self.secret_access_key = secret_access_key
          credentials_file = "#{Dir.home}/.#{partition}/credentials"
          return unless File.exists?(credentials_file)
          if credentials = IniFile.load(credentials_file)[profile]
            self.profile = profile
            self.access_key_id = credentials["#{partition}_access_key_id"]
            self.secret_access_key = credentials["#{partition}_secret_access_key"]
          end
        end

        def partition
          @partition ||= Settings.partition_name
        end

        def authorization
          @authorization ||= "#{Settings.auth_type} #{access_key_id}:#{secret_access_key}"
        end
      end
    end

    class Client
      class << self
        attr_accessor :scheme, :host, :domain, :port, :force_path_style, :service

        def configure(scheme: 'https', host: nil, domain: nil, port: nil, force_path_style: false, service: nil, connection_type: 'host', prefix: nil, postfix: nil)
          if descendants.any?
            descendants.map(&:to_s).sort.each do |client|
              client.constantize.configure(scheme: scheme, host: host, domain: domain, port: port, force_path_style: force_path_style, service: service)
              port += 1 if connection_type.eql? 'port'
            end
            return
          end
          self.scheme = scheme
          self.host = host
          self.domain = domain
          self.port = port
          self.force_path_style = force_path_style
          self.service = (service || parent.name.split('::').last).downcase
          Ros::Sdk.configured_services ||= {}
          Ros::Sdk.configured_services[self.service] = parent
          parent::Base.site = endpoint
          parent::Base.connection.use Ros::Sdk::Middleware
          Ros::Sdk.configured_services[self.service]
        end

        def endpoint
          path = force_path_style ? "/#{service}" : nil
          chost = force_path_style ? host : (host || service)
          chost = [chost, domain].compact.join('.')
          "URI::#{scheme.upcase}".constantize.build({ host: chost, port: port, path: path }).to_s
        rescue
          raise 'ClientConfigurationError'
        end
      end
    end
  end

  module Platform
    class Client < Ros::Sdk::Client; end
  end
end

PryCommandSet = Pry::CommandSet.new

class ConsoleHelp < Pry::ClassCommand
  match 'setup-client'
  group 'ros'
  description 'Setup client'
  banner <<-BANNER

  Client with service on localhost:
    external: self.setup(scheme: 'http', host: 'localhost', domain: nil, port: 3000, force_path_style: false)
    internal: self.setup(scheme: 'http', host: 'localhost', domain: nil, port: 3001, force_path_style: false)

  Compose with nginx paths on single port for all services:
    external: self.setup(scheme: 'http', host: 'localhost', domain: nil, port: 3000, force_path_style: true)
    internal: self.setup(scheme: 'http', host: nil, domain: nil, port: 3000, force_path_style: false)

  Kubernetes:
    external: self.setup(scheme: nil, host: nil, domain: 'rails-on-services.io', port: nil, force_path_style: false)
    internal: self.setup(scheme: 'http', host: nil, domain: nil, port: 3000, force_path_style: false)
  BANNER

  def process; end
  PryCommandSet.add_command(self)
end

=begin
class RServices < Pry::ClassCommand
  match 'services'
  group 'ros'

  def process; Ros::Sdk.configured_services end
  PryCommandSet.add_command(self)
end

class REndpoints < Pry::ClassCommand
  match 'endpoints'
  group 'ros'

  def process; Ros::Sdk.service_endpoints end
  PryCommandSet.add_command(self)
end
=end

Pry.config.commands.import PryCommandSet
