# frozen_string_literal: true

module Ros
  module JsonapiAuthorization
    class Authorizer < JSONAPI::Authorization::DefaultPunditAuthorizer
      def find(source_class:)
        binding.pry
        super
      end

      def show(source_record:)
        binding.pry
        super
      end
    end
  end
end
