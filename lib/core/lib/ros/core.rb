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
# require 'pry-remote'

require_relative 'tenant_middleware'
require_relative 'dtrace_middleware'
require_relative 'url_builder'
require_relative 'api_token_strategy'
require_relative 'routes'
require_relative '../migrations'

require 'ros/core/engine'

module Ros
  module Core
  end

  class << self
    def host_tmp_dir; "tmp/#{Settings.feature_set}" end

    def host_env; @host_env ||= ActiveSupport::StringInquirer.new(File.exist?('/.dockerenv') ? 'docker' : 'os') end

    def root
      @root ||= begin
                  cwd = Pathname.new(Dir.pwd)
                  Dir.pwd.split('/').size.times do |i|
                    path = cwd.join('../' * i)
                    break path if Dir.exist?("#{path}/services") && Dir.exist?("#{path}/lib")
                  end
                end
    end

    def spec_root; @spec_root ||= Pathname.new(__FILE__).join('../../../spec') end

    def dummy_mount_path; @dummy_mount_path ||= "/#{host_env.os? ? Settings.service.name : ''}" end

    # TODO: Tenant events and platform events are skipped for now; these will support callbacks
    def table_names
      @table_names ||= begin
        ActiveRecord::Base.connection.tables - %w[schema_migrations ar_internal_metadata tenant_events platform_events]
      end
    end

    def api_calls_enabled; Settings.dig(:api_calls_enabled) || !Rails.env.test? end

    # By default all services exclude only the Tenant model from schemas
    def excluded_models; %w[Tenant] end
  end

  # TODO: Authorize method
  # TODO: scope value is the subject's policies; What if the subject's policies change after token issued?
  # It could be that every token expires in 10 minutes or something which means that the auth strategy
  # would check and then re-issue a token as long as the user is still valid;
  # this would update permissions at that point
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
      token.merge(aud: aud, iat: issued_at)
    end

    def add_claims(claims)
      claims.each_pair { |k, v| @claims[k] = k.in?(Settings.dig(:jwt, :valid_claims)) ? v : [] }
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
      return unless (urn_string = jwt.decode['sub'])

      from_urn(urn_string)
    # NOTE: Intentionally swallow decode error and return nil
    # rubocop:disable Lint/HandleExceptions
    rescue JWT::DecodeError
    end
    # rubocop:enable Lint/HandleExceptions

    # rubocop:disable Naming/PredicateName
    def is_platform_urn?; account_id.eql?('platform') end
    # rubocop:enable Naming/PredicateName

    def resource_type; resource.split('/').first end

    def resource_id; resource.split('/').last end

    def model_name; resource_type.classify end

    def model; model_name.constantize end

    # rubocop:disable Rails/DynamicFindBy
    def instance; model.find_by_urn(resource_id) end
    # rubocop:enable Rails/DynamicFindBy

    def to_s; to_a.join(':') end
  end

  # Failure response to return JSONAPI error message when authentication fails
  class FailureApp
    def self.call(_env)
      [401, { 'Content-Type' => 'application/vnd.api+json' },
       [{ errors: [{ status: '401', title: 'Unauthorized' }] }.to_json]]
    end
  end
end
