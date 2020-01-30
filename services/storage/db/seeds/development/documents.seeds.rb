# frozen_string_literal: true

after 'development:transfer_maps' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      Settings.api_calls_enabled = false

      transfer_map = TransferMap.first

      FactoryBot.create(:document, transfer_map: transfer_map)

      Settings.api_calls_enabled = true
    end
  end
end
