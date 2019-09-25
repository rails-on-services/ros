# frozen_string_literal: true

# rubocop:disable UselessAssignment
start_id = (Tenant.last&.id || 0) + 1
(start_id..start_id + 1).each do |id|
  is_even = (id % 2).zero?
  Tenant.create!(
    schema_name: Tenant.account_id_to_schema(id.to_s * 9),
    platform_properties: { login_attribute_key: :primary_identifier }
  )
end
# rubocop:enable UselessAssignment
