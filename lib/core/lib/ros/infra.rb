# frozen_string_literal: true

module Ros
  module Infra
    module Storage
      extend ActiveSupport::Concern

      def ls(path = ''); raise NotImplementedError end
      def get(path); raise NotImplementedError end
      def put(path); raise NotImplementedError end
    end

    module Mq
      extend ActiveSupport::Concern
    end
  end
end
