# frozen_string_literal: true

class ChownEnqueuedConsumer < ApplicationConsumer
  include Karafka::Consumers::Callbacks

  after_fetch :set_tenant_env

  def consume
    params_batch.each do |params|
      schema_name = params['schema_name']

      Apartment::Tenant.switch!(schema_name)
      next unless (@tenant = Tenant.find_by(schema_name: schema_name))

      @tenant.set_role_credential

      create_chown_result(params)
    end
  end

  private

  def create_chown_result(params)
    payload = params['payload']
    ChownResult.create(chown_request_id: params['record_urn'].resource_id,
                       service_name: payload['service_name'],
                       from_id: payload['from_id'], to_id: payload['to_id'], status: 'pending')
  end

  def set_tenant_env
    params_batch.each do |params|
      payload = params['payload']
      record_urn = Ros::Urn.from_urn(payload['record']['urn'])
      if record_urn.nil?
        Rails.logger.debug("record_urn is nil. PAYLOAD: #{payload.inspect}")
        next
      end
      params['record_urn'] = record_urn
      params['schema_name'] = Tenant.account_id_to_schema(record_urn.account_id)
    end
  end
end
