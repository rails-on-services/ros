# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    is_even = (tenant.id % 2).zero?
    next if tenant.id.eql? 1
    tenant.switch do
    end
  end
end
