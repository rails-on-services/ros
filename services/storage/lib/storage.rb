# frozen_string_literal: true

require 'ros/core'
require 'storage/engine'

module Storage
  module Methods
    # rubocop:disable Naming/AccessorMethodName
    def set_bucket(bucket)
      @bucket = @client.bucket(bucket)
    end
    # rubocop:enable Naming/AccessorMethodName
  end
end
