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
require 'sidekiq'
require 'sidekiq/web'
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

  # def self.host_tmp_dir; "tmp/#{ENV['PLATFORM__FEATURE_SET']}" end
  def self.host_tmp_dir; "tmp/#{Settings.feature_set}" end

  # NOTE: Experimental
  class Application
    def self.config; Settings end
  end

  class << self
    attr_accessor :config

    def config; @config ||= Ros::Configuration.new end
    def version; '0.1.0' end
    def application; Application end
  end
  # NOTE: End Experimental


  # TODO: Authorize method
  # TODO: scope value is the subject's policies; What if the subject's policies change after token issued?
  # It could be that every token expires in 10 minutes or something which means that the auth strategy
  # would check and then re-issue a token as long as the user is still valid; this would update permissions at that point
  # or it would need to check if the user has been updated since the token was issued
  # def self.issue(iss: Ros::Sdk.service_endpoints['iam'], sub:, scope:)
  #   issued_at = Time.now.to_i
  #   token = { iss: iss, aud: ['this_domain'], sub: sub, scope: scope, iat: issued_at }
  #   token.merge!(exp: issued_at + expires_in) if expires_in = Settings.dig(:jwt, :token_expires_in_seconds)
  #   token
  # end
  class Jwt
    attr_reader :claims, :token

    def initialize(payload)
      if payload.is_a? Hash # From IAM::User, IAM::Root
        @claims = payload.merge(default_payload)
      else # From a bearer token
        @token = payload.gsub('Bearer ', '')
        decode
      end
    end

    def default_payload
      issued_at = Time.now.to_i
      token = (expires_in = Settings.dig(:jwt, :token_expires_in_seconds)) ? { exp: issued_at + expires_in } : {}
      token.merge({ aud: aud, iat: issued_at })
    end

    def add_claims(claims)
      claims.each_pair { |k, v| @claims[k] = v if k.in? Settings.dig(:jwt, :valid_claims) || [] }
      self
    end

    # TODO: Set audience from the issuer's domain name
    def aud; [Settings.jwt.aud || 'undefined'] end

    def encode
      @token = JWT.encode(claims, encryption_key, alg)
    end

    def decode
      @claims = JWT.decode(token, encryption_key, alg).first
    end

    def alg; Settings.jwt.alg end

    def encryption_key; Settings.jwt.encryption_key end
  end

  Urn = Struct.new(:txt, :partition_name, :service_name, :region, :account_id, :resource) do
    def self.from_urn(urn_string)
      urn_array = urn_string.split(':')
      new(*urn_array)
    end

    def self.from_jwt(token)
      jwt = Jwt.new(token)
      return unless urn_string = jwt.decode['sub']
      from_urn(urn_string)
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
