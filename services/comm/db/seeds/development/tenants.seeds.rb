# frozen_string_literal: true

Tenant.find_or_create_by(schema_name: 'public')

1.upto(7) do |id|
  Tenant.find_or_create_by(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
end
