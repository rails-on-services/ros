# frozen_string_literal: true

after 'development:users' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      User.all.each do |user|
        FactoryBot.create(:identifier, user: user)
      end
    end
  end
end
