# frozen_string_literal: true

# rubocop:disable Lint/UselessAssignment
after 'development:tenants' do
  Tenant.all.each do |tenant|
    is_even = (tenant.id % 2).zero?
    next if tenant.id.eql? 1

    tenant.switch do
      first_org = FactoryBot.create(:org)
      FactoryBot.create(:branch, org: first_org)
    end
  end
end
# rubocop:enable Lint/UselessAssignment
