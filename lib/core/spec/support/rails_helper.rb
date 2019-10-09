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
    Apartment::Tenant.switch! @as.schema_name
  end
  config.after(:all) do
    Apartment::Tenant.switch! 'public'
    @as.destroy
    @as.root.destroy if @as.try(:root) # IAM only
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

RSpec::Matchers.define :permit do |action|
  match do |policy|
    policy.public_send("#{action}?")
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} on #{policy.record} for #{policy.user.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} on #{policy.record} for #{policy.user.inspect}."
  end
end

Dir[Ros.spec_root.join('shared/**/*.rb')].each { |f| require f }
