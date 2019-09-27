# frozen_string_literal: true

1.upto(6) do |id|
  tenant = Tenant.create!(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
  tenant.update(platform_twilio_enabled: true) if id == 1
end
