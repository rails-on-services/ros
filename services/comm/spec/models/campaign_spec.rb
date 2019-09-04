# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campaign, type: :model do
  it_behaves_like 'it belongs_to_resource', :owner
  it_behaves_like 'it belongs_to_resource', :cognito_endpoint
end
