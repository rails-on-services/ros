# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      # Endpoint.create(url: "http://tenant#{tenant.id}.com/hello", target_type: 'Survey::Group', target_id: 1)
      # Endpoint.create(url: 'http://i.pxln.io/59dcb', target_type: 'Survey::Campaign', target_id: 1)
      # User.reset
      # file_name = 'cognito_pools.csv'
      # User.load_csv(file_name)
      Pool.create(name: 'Developers').tap do |pool|
        pool.users.create(primary_identifier: 'developer', title: 'Mr', last_name: 'Developer',
                          phone: '+15855551212')
      end
      Pool.create(name: 'Gold Tier').tap do |pool|
        pool.users.create(primary_identifier: 'jones', title: 'Mr', last_name: 'Jones', phone: '+1388200363')
        pool.users.create(primary_identifier: 'miller', title: 'Mrs', last_name: 'Miller', phone: '+1396537757')
        pool.users.create(primary_identifier: 'doe', title: 'Miss', last_name: 'Doe', phone: '+1382800710')
      end
      Pool.create(name: 'Silver Tier').tap do |pool|
        pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Ms', last_name: 'Shelly', phone: '')
        pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Homes', phone: '')
        pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Lucas', phone: '')
      end
    end
  end
end
