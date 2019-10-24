# frozen_string_literal: true

module Ros
  class Urn
    attr_accessor :txt, :partition_name, :service_name, :region, :account_id, :resource

    def initialize(txt, partition_name, service_name, region, account_id, resource)
      @txt = txt
      @partition_name = partition_name
      @service_name = service_name
      @region = region
      @account_id = account_id
      @resource = resource
    end

    def self.from_urn(urn_string)
      urn_array = urn_string.split(':')
      new(*urn_array)
    end

    def self.from_jwt(token)
      jwt = Jwt.new(token)
      return unless (urn_string = jwt.decode['sub'])

      from_urn(urn_string)
    # NOTE: Intentionally swallow decode error and return nil
    # rubocop:disable Lint/HandleExceptions
    rescue JWT::DecodeError
    end
    # rubocop:enable Lint/HandleExceptions

    def resource_type; resource.split('/').first end

    def resource_id; resource.split('/').last end

    def model_name; resource_type.classify end

    def model; model_name.constantize end

    # rubocop:disable Rails/DynamicFindBy
    def instance; model.find_by_urn(resource_id) end
    # rubocop:enable Rails/DynamicFindBy

    def to_s; to_a.join(':') end
  end
end
