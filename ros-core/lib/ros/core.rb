# frozen_string_literal: true

# Require gems from gemspec so they are available to the gems that depend on ros-core
require 'seedbank'
require 'apartment'
require 'jsonapi-resources'
require 'jsonapi/authorization'
require 'attr_encrypted'
require 'pry'
require 'jwt'
require 'warden'
require 'config'
require 'ros_sdk'

require_relative 'tenant_middleware'
require_relative 'api_token_strategy'
require_relative 'routes'

require 'ros/core/engine'

module Ros
  class Configuration
    attr_accessor :model_paths, :factory_paths

    def initialize; @model_paths = []; @factory_paths = [] end
  end

  class << self
    attr_accessor :config

    def config; @config ||= Ros::Configuration.new end
  end

  class Jwt
    def self.encode(payload)
      # TODO: This is called twice by IAM on basic auth
      JWT.encode(payload, Settings.credentials.jwt_encryption_key, Settings.jwt.alg)
    end

    def self.decode(payload)
      JWT.decode(payload, Settings.credentials.jwt_encryption_key, Settings.jwt.alg)
    end
  end

  Urn = Struct.new(:txt, :partition_name, :service_name, :region, :account_id, :resource) do
    def self.from_jwt(token)
      jwt = Jwt.decode(token)
      return unless urn_string = jwt[0]['urn']
      urn_array = urn_string.split(':')
      new(*urn_array)
    # NOTE: Intentionally swallow decode error and return nil
    rescue JWT::DecodeError
    end

    def resource_type; resource.split('/').first end
    def resource_id; resource.split('/').last end

    def model_name; resource_type.classify end
    def model; model_name.constantize end
    def instance; model.find_by_urn(resource_id) end
    def to_s; to_a.join(':') end
  end

  # Failure response to return JSONAPI error message when authentication failse
  class FailureApp
    def self.call(env)
      [401, { 'Content-Type' => 'application/vnd.api+json' },
        [{ errors: [{ status: '401', title: 'Unauthorized' }] }.to_json]]
    end
  end

  module Core
  end
end
