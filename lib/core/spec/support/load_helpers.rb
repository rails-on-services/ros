# frozen_string_literal: true

if defined?(Devise)
  RSpec.configure do |config|
    config.include LoginSpecHelper
    config.include Devise::Test::IntegrationHelpers, type: :request
  end
end
