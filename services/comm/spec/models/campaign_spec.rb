# frozen_string_literal: true

require 'rails_helper'
require 'ros/matchers/belongs_to_resource_matcher'

RSpec.describe Campaign, type: :model do
  it_behaves_like 'it belongs_to_resource', :owner
  it_behaves_like 'it belongs_to_resource', :cognito_endpoint
end
