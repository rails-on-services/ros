# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1
    tenant.switch do
      Endpoint.create(url: "http://tenant#{tenant.id}.com/hello", target_type: 'Survey::Group', target_id: 1)
      Endpoint.create(url: 'https://microsite.org/my/site', target_type: 'Survey::Campaign', target_id: 1)
      User.reset
      Pool.create(name: 'Group I').tap do |pool|
        pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Smith', phone_number: '+1581132988')
        pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Miller', phone_number: '+1588200363')
        pool.users.create(primary_identifier: SecureRandom.uuid, title: 'Mr', last_name: 'Jones', phone_number: '+1596537757')
      end
    end
  end
end
