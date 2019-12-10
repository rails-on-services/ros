# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SegmentedPoolCreate, type: :operation do
  include ActiveSupport::Testing::TimeHelpers

  let(:base_pool) { create(:pool) }
  let(:op_params) { {} }
  let(:base_pool_id) { base_pool.id }
  let(:op_result) { described_class.call(params: op_params, base_pool_id: base_pool_id, segments: segments) }

  before do
    create(:user, birthday: Time.zone.today)
    create_list(:user, 5)
    base_pool.users << User.all
  end

  context 'with segment specified' do
    let(:segments) { { 'birthday' => 'this_day' } }

    it 'returns successfull result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.users.size).to eq(1)
    end
  end

  context 'without segments specified' do
    let(:segments) { {} }

    it 'returns successfull result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.users.size).to eq(6)
    end
  end

  context 'with non-matching segment' do
    let(:segments) { { 'birthday' => 'this_day' } }

    before do
      travel_to Time.zone.today - 1.month
    end

    it 'returns unsuccessfull result' do
      expect(op_result.success?).to be_falsey
      expect(op_result.errors[:users].first).to eq("Can't fetch users for pool")
    end
  end
end
