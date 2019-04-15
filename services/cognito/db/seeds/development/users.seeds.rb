# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1
    tenant.switch do
      Endpoint.create(url: "http://tenant#{tenant.id}.com/hello", target_type: 'Survey::Group', target_id: 1)
      Endpoint.create(url: 'http://i.pxln.io/59dcb', target_type: 'Survey::Campaign', target_id: 1)
      User.reset
      # file_name = 'cognito_pools.csv'
      # User.load_csv(file_name)
      # Pool.create(name: 'Internal Testers - Phase I').tap do |pool|
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Smith', phone_number: '+1381132988')
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Jones', phone_number: '+1388200363')
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Miller', phone_number: '+1396537757')
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Doe', phone_number: '+1382800710')
      # end
      # Pool.create(name: 'Internal Testers - Phase II').tap do |pool|
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Ms', last_name: 'Shelly', phone_number: '')
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Homes', phone_number: '')
      #   pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Lucas', phone_number: '')
      # end
    end
  end
end
