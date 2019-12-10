# frozen_string_literal: true

module IronHide
  class Storage
    class ServiceAdapter < FileAdapter
      def initialize; end

      def where(opts = {})
        keys = opts[:user].attached_policies.keys
        policy = Settings.dig(:service, :policies)
        json = policy.select { |p| keys.include?(p['name']) }.map { |j| j['rules'] }.flatten
        @rules = unfold(json)
        # @rules = unfold(opts[:user].attached_policies)
        self[opts[:resource]][opts[:action]]
      end
    end
  end
end

# Add adapter class to IronHide::Storage
IronHide::Storage::ADAPTERS.merge!(service: :ServiceAdapter)
