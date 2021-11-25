# frozen_string_literal: true

binding.pry
Tenant.create(schema_name: 'public')

1.upto(7) do |id|
  Tenant.create!(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
end
