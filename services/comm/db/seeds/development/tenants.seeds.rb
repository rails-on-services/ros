# frozen_string_literal: true

Tenant.create(schema_name: 'public', platform_twilio_enabled: true)

2.upto(7) do |id|
  Tenant.create!(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
end
