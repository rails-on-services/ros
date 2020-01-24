# frozen_string_literal: true

require 'pry'

require 'active_support/core_ext/class/attribute'
require 'json_api_client'
require 'faraday_middleware'
require 'ros_sdk/sdk'
require 'ros_sdk/middleware'
require 'ros_sdk/models'

Dir[File.expand_path('lib/ros_sdk/*.rb')].each { |f| require f }
