# frozen_string_literal: true

class ChownStatusChangedConsumer < ApplicationConsumer
  include Karafka::Consumers::Callbacks

  def consume
    params_batch.each do |params|
      schema_name = params['payload']['schema_name']

      Apartment::Tenant.switch!(schema_name)
      next unless (@tenant = Tenant.find_by(schema_name: schema_name))

      @tenant.set_role_credential

      update_chown_status(params)
    end
  end

  private

  def update_chown_status(params)
    payload = params['payload']
    result = ChownResult.find_by(chown_request_id: payload['chown_request_id'],
                                 service_name: payload['service_name'])
    result.update(status: payload['status'])
  end
end
