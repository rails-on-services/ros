# frozen_string_literal: true

class ChownEnqueuedConsumer < ApplicationConsumer
  def consume
    params_batch.each do |params|
      schema_name = params['payload']['schema_name']

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
end
