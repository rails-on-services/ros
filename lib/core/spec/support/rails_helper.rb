# frozen_string_literal: true

require 'faker'
require 'shoulda-matchers'
require 'airborne'
require 'factory_bot_rails'

Airborne.configure do |config|
  config.verify_ssl = false # equivalent to OpenSSL::SSL::VERIFY_NONE
  config.base_url = Ros.dummy_mount_path
end

# Create tenant once per suite is 25% faster than creating a tenant (and schema) once per test
# To enable tenant per test, comment out below and swap the let(:tenant) statements below
RSpec.configure do |config|
  config.before(:all) do
    @as = create(:tenant, schema_name: '222_222_222')
  end
  config.after(:all) do
    @as.destroy
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end

# RSpec.configure do |config|
#   config.before(:suite) do
#     DatabaseCleaner.strategy = :transaction
#     DatabaseCleaner.clean_with(:deletion)
#   end
# 
#   config.around(:each) do |example|
#     DatabaseCleaner.cleaning do
#       example.run
#     end
#   end
# end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end


Dir[Ros.spec_root.join('shared/**/*.rb')].each { |f| require f }
