# frozen_string_literal: true

module Ros
  module UrlBuilder
    module JSONAPI
      class LinkBuilder
        def base_url
          return @base_url if service_engine_name.blank?

          "#{@base_url}/#{service_engine_name}"
        end

        private

        def service_engine_name
          primary_resource_klass.superclass.to_s.split('::')[0...-1].first&.underscore
        end
      end
    end
  end
end
