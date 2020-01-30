# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      first_org = FactoryBot.create(:org)
      FactoryBot.create(:branch, org: first_org)
    end
  end
end
