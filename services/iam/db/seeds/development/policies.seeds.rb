# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      FactoryBot.create(:policy, name: 'AdministratorAccess') if Policy.count.zero?
    end
  end
end
