# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SegmentedPoolCreate, type: :operation do
  let(:base_pool) { create(:pool) }
  let(:op_params) { {} }
  let(:base_pool_id) { base_pool.id }
  let(:segments) { { birthday: 'this_day' } }
  let(:op_result) { described_class.call(params: op_params, base_pool_id: base_pool_id, segments: segments) }

  it 'returns successfull result' do
    expect(op_result.success?).to be_truthy
    # binding.pry
  end
end
