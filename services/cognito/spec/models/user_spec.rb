# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:subject) { create(factory_name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:user_pools) }
    it { is_expected.to have_many(:pools).through(:user_pools) }
  end

  describe 'anonymous' do
    it 'defaults to false' do
      user = described_class.new
      expect(user.anonymous).to eq false
    end
  end
end
