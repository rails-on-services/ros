# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      Settings.api_calls_enabled = false

      FactoryBot.create(:transfer_map)

      Settings.api_calls_enabled = true
    end
  end
end
