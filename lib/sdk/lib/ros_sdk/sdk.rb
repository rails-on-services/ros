# frozen_string_literal: true

require 'globalid'
require_relative '../../../../lib/core/app/policies/ros/application_policy'

module Ros
  module Sdk
    class << self
      attr_accessor :configured_services

      def service_endpoints
        configured_services.each_with_object({}) do |service, hash|
          hash[service[0]] = service[1]::Base.site
        end
      rescue StandardError
        raise ClientConfigurationError
      end
    end

    class ClientConfigurationError < StandardError; end

    class JsonApiPaginator < JsonApiClient::Paginating::Paginator
      self.page_param = 'number'
      self.per_page_param = 'size'
    end

    class Base < JsonApiClient::Resource
      self.paginator = JsonApiPaginator
      attr_writer :to_gid

      def to_gid
        @to_gid ||= GlobalID.new("gid://internal/#{self.class.name}/#{id}")
      end

      def to_urn
        urn
      end
    end

    class Credential
      class << self
        attr_accessor :access_key_id, :secret_access_key, :region
        attr_writer :partition, :authorization, :request_headers

        def configure(access_key_id: nil, secret_access_key: nil)
          self.access_key_id = access_key_id
          self.secret_access_key = secret_access_key
        end

        def request_headers
          @request_headers ||= {}
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

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/ParameterLists
        # rubocop:disable Lint/UnusedMethodArgument
        def configure(scheme: 'https', host: nil, domain: nil, port: nil, force_path_style: false,
                      service: nil, connection_type: 'host', prefix: nil, postfix: nil)
          if descendants.any?
            descendants.map(&:to_s).sort.each do |client|
              client.constantize.configure(scheme: scheme, host: host, domain: domain, port: port,
                                           force_path_style: force_path_style, service: service)
              port += 1 if connection_type.eql? 'port'
            end
            return
          end
          self.scheme = scheme
          self.host = host
          self.domain = domain
          self.port = port
          self.force_path_style = force_path_style
          self.service = (service || module_parent.name.split('::').last).downcase
          Ros::Sdk.configured_services ||= {}
          Ros::Sdk.configured_services[self.service] = module_parent
          module_parent::Base.site = endpoint
          module_parent::Base.connection.use Ros::Sdk::Middleware
          Ros::Sdk.configured_services[self.service]
        end
        # rubocop:enable Lint/UnusedMethodArgument
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/ParameterLists
        # rubocop:enable Metrics/AbcSize

        # rubocop:disable Metrics/AbcSize
        def endpoint
          path = force_path_style ? "/#{service}" : nil
          chost = force_path_style ? host : (host || service)
          chost = [chost, domain].compact.join('.')
          "URI::#{scheme.upcase}".constantize.build(host: chost, port: port, path: path).to_s
        rescue StandardError
          raise 'ClientConfigurationError'
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end

  module Platform
    class Client < Ros::Sdk::Client; end
  end
end

Ros::Sdk::PryCommandSet = Pry::CommandSet.new

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
  Ros::Sdk::PryCommandSet.add_command(self)
end

class RServices < Pry::ClassCommand
  match 'sdk'
  group 'ros'
  description 'show SDK configured services and endpoints'

  def process
    output.puts "Services: #{Ros::Sdk.configured_services}"
    output.puts "Endpoints: #{Ros::Sdk.service_endpoints}"
  end

  Ros::Sdk::PryCommandSet.add_command(self)
end

Pry.config.commands.import Ros::Sdk::PryCommandSet
