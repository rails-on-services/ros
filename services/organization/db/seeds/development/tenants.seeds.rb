# frozen_string_literal: true

t = Tenant.create(schema_name: 'public')
puts t.errors if t.errors.length > 0

1.upto(6) do |id|
  schema_name = Tenant.account_id_to_schema(id.to_s * 9)
  puts "CREATING #{schema_name}"
  Tenant.create!(schema_name: schema_name)
end
