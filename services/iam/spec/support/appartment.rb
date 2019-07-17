# RSpec.configure do |config|
#   config.before(:suite) do
#     # Clean all tables to start
#     DatabaseCleaner.clean_with :truncation
#     # Use transactions for tests
#     DatabaseCleaner.strategy = :transaction
#     # Create the default tenant for our tests
#   end
#
#   config.after(:each) do
#     # Reset tentant back to `public`
#     Apartment::Tenant.reset
#     # Rollback transaction
#     DatabaseCleaner.clean
#   end
# end