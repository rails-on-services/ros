# frozen_string_literal: true

RSpec.configure do |config|
  config.include LoginSpecHelper
  config.include Devise::Test::IntegrationHelpers, type: :request
end
