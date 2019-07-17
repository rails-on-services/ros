# frozen_string_literal: true

RSpec.configure do |config|
  config.include LoginSpecHelper, helpers: :login
  config.include Devise::Test::IntegrationHelpers, type: :request
end
