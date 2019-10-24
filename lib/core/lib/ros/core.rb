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
require 'trailblazer/activity'
require 'trailblazer/activity/dsl/linear'
# require 'pry-remote'

require_relative 'tenant_middleware'
require_relative 'dtrace_middleware'
require_relative 'url_builder'
require_relative 'jsonapi_authorization/authorizer'
require_relative 'api_token_strategy'
require_relative 'routes'
require_relative 'urn'
require_relative 'jwt'
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

  # Failure response to return JSONAPI error message when authentication fails
  class FailureApp
    def self.call(_env)
      [401, { 'Content-Type' => 'application/vnd.api+json' },
       [{ errors: [{ status: '401', title: 'Unauthorized' }] }.to_json]]
    end
  end
end
