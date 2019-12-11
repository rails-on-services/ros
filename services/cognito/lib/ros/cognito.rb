# frozen_string_literal: true

require 'ros/core'
require 'ros/cognito/engine'

module Ros
  module Cognito
    # Your code goes here...
  end

  class << self
    def excluded_models
      %w[Tenant MetabaseCard]
    end
  end
end
