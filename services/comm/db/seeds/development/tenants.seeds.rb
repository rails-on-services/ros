# frozen_string_literal: true

# rubocop:disable Lint/UselessAssignment
start_id = (Tenant.last&.id || 0) + 1
(start_id..start_id + 1).each do |id|
  is_even = (id % 2).zero?
  tenant = Tenant.create!(schema_name: Tenant.account_id_to_schema(id.to_s * 9))
  tenant.update(platform_twilio_enabled: true) if id == 1
end
# rubocop:enable Lint/UselessAssignment
