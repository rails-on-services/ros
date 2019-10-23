# frozen_string_literal: true

module Ros
  module Infra
    module Storage
      extend ActiveSupport::Concern

      class << self
        def resource_type; :buckets end
      end

      def ls(_path = ''); raise NotImplementedError end

      def get(_path); raise NotImplementedError end

      def put(_path); raise NotImplementedError end
    end
  end
end
