# frozen_string_literal: true

RSpec.configure do |config|
  config.include ApiJsonSpecHelper
  if defined?(Devise)
    config.include LoginSpecHelper
    config.include Devise::Test::IntegrationHelpers, type: :request
  end
end
