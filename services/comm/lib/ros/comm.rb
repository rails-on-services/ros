# frozen_string_literal: true

require 'twilio-ruby'
require 'aws-sdk-sns'

require 'ros/comm/engine'

module Ros
  module Comm
  end

  class << self
    def excluded_models
      %w[Tenant Provider]
    end
  end
end
