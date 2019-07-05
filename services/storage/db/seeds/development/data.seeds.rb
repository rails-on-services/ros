# frozen_string_literal: true

# rubocop:disable Lint/UselessAssignment
after 'development:tenants' do
  Tenant.all.each do |tenant|
    is_even = (tenant.id % 2).zero?
    next if tenant.id.eql? 1

    tenant.switch do
      TransferMap.create(name: 'New Customer Survey Lists', description: '', service: 'cognito',
                         target: 'user').tap do |map|
        map.column_maps.create(name: 'title', user_name: 'Salutation')
        map.column_maps.create(name: 'last_name', user_name: 'Last Name')
        map.column_maps.create(name: 'phone_number', user_name: 'Mobile')
        map.column_maps.create(name: 'primary_identifier', user_name: 'Unique Number')
        map.column_maps.create(name: 'pool_name', user_name: 'Campaign')
      end
    end
  end
end
# rubocop:enable Lint/UselessAssignment
