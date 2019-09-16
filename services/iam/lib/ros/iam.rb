# frozen_string_literal: true

require 'bcrypt'
require 'devise'
# require 'devise/jwt'

require 'ros/core'
require_relative 'api_token_strategy'
require_relative 'tenant_middleware'
require 'ros/iam/engine'

module Ros
  class << self
    def excluded_models; %w[Tenant Root] end
  end
  module Iam
    # Your code goes here...
  end
end
