# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Branch, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let!(:subject) { create(factory_name) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:org) }
  end
end
