# frozen_string_literal: true

module Ros
  module ScopableConcern
    extend ActiveSupport::Concern

    class_methods do
      def everything(_user_context)
        all
      end

      def owned(_user_context)
        all
      end
    end
  end
end
