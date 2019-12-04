# frozen_string_literal: true

module IronHide
  class Storage
    class ServiceAdapter < FileAdapter

      def initialize
      end

      def where(opts = {})
        #  Settings.dig(:service, :policies))
        json.select { |p| p['name'].eql?('CognitoPowerUser') }
        @rules = unfold(opts[:user].attached_policies)
        self[opts[:resource]][opts[:action]]
      end
    end
  end
end

# Add adapter class to IronHide::Storage
IronHide::Storage::ADAPTERS.merge!(service: :ServiceAdapter)
