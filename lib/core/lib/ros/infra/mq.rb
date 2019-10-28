# frozen_string_literal: true

module Ros
  module Infra
    module Mq
      extend ActiveSupport::Concern

      class << self
        def resource_type; :queues end
      end
    end
  end
end
