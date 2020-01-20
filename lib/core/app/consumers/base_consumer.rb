# frozen_string_literal: true

# Application consumer from which all Karafka consumers should inherit
# You can rename it if it would conflict with your current code base (in case you're integrating
# Karafka with other frameworks)

module Ros
  class BaseConsumer < Karafka::BaseConsumer
    include Karafka::Consumers::Callbacks

    after_fetch :set_tenant_env

    def set_tenant_env
      params_batch.each do |params|
        Rails.logger.debug "[Karafka::Consumer]: #{params.inspect}"
        payload = params['payload']
        next if payload.blank?

        record_urn = Ros::Urn.from_urn(payload['record']['urn'])
        if record_urn.nil?
          Rails.logger.debug("record_urn is nil. PAYLOAD: #{payload.inspect}")
          next
        end
        params['record_urn'] = record_urn
      end
    end
  end
end
