# frozen_string_literal: true

Tenant.create(schema_name: 'public', platform_twilio_enabled: true)

1.upto(6) do |id|
  Tenant.create!(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
end
