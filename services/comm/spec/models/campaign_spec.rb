# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campaign, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let!(:subject) { create(factory_name) }
  end
end
