# frozen_string_literal: true

module Ros
  module Infra
    module Storage
      extend ActiveSupport::Concern

      def ls(_path = ''); raise NotImplementedError end

      def get(_path); raise NotImplementedError end

      def put(_path); raise NotImplementedError end
    end

    module Mq
      extend ActiveSupport::Concern
    end
  end
end
