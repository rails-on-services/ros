# frozen_string_literal: true

# Require gems from gemspec so they are available to the gems that depend on ros-core
require 'apartment'
require 'attr_encrypted'
require 'config'
require 'hashids'
require 'jsonapi-resources'
require 'jsonapi/authorization'
require 'jwt'
require 'pry'
require 'ros_sdk'
require 'rufus-scheduler'
require 'seedbank'
require 'sidekiq'
require 'sidekiq/web'
require 'trailblazer/activity'
require 'trailblazer/activity/dsl/linear'
require 'warden'

require_relative 'api_token_strategy'
require_relative 'dtrace_middleware'
require_relative 'jsonapi_authorization/authorizer'
require_relative 'jwt'
require_relative '../migrations'
require_relative 'routes'
require_relative 'scheduler/tenant_handler'
require_relative 'tenant_middleware'
require_relative 'url_builder'
require_relative 'urn'

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
      @table_names ||= ActiveRecord::Base.connection.tables - excluded_table_names
    end

    def excluded_table_names
      %w[schema_migrations ar_internal_metadata tenant_events platform_events]
    end

    def api_calls_enabled
      Settings.dig(:api_calls_enabled).nil? ? !Rails.env.test? : Settings.dig(:api_calls_enabled)
    end

    # By default all services exclude only the Tenant model from schemas
    def excluded_models; %w[Tenant] end
  end

  class AccessKey
    def self.generate(owner)
      Rails.configuration.x.hasher.encode(
        Rails.configuration.x.hash_version,
        owner.class.name.eql?('Root') ? owner.tenant.account_id : Apartment::Tenant.current.to_i,
        owner.class.name.eql?('Root') ? 0 : 1,
        owner.id,
        Time.zone.now.to_i
      )
    end

    def self.decode(access_key_id)
      version, account_id, owner_type, owner_id, created_at = Rails.configuration.x.hasher.decode(access_key_id)
      return { version: 0, account_id: 0, owner_type: nil, owner_id: 0, schema_name: 'public' } if version.nil?

      { version: version, account_id: account_id, owner_id: owner_id,
        owner_type: owner_type.zero? ? 'Root' : 'User',
        schema_name: Tenant.account_id_to_schema(account_id),
        created_at: Time.zone.at(created_at) }
    rescue Hashids::InputError
      { version: 0, account_id: 0, owner_type: nil, owner_id: 0, schema_name: 'public' }
    end
  end

  # Failure response to return JSONAPI error message when authentication fails
  class FailureApp
    def self.call(_env)
      [401, { 'Content-Type' => 'application/vnd.api+json' },
       [{ errors: [{ status: '401', title: 'Unauthorized' }] }.to_json]]
    end
  end
end
