# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PoolCreate, type: :operation do
  let(:user) { double(PolicyUser, root?: true) }
  let(:op_result) { described_class.call(params: op_params, user: user) }

  context 'regular pool creation' do
    let(:pool_name) { 'sample pool' }
    let(:op_params) { { name: pool_name } }

    it 'returns successful result' do
      expect(op_result.success?).to eq true
      expect(op_result.model.persisted?).to eq true
      expect(op_result.model.system_generated?).to eq false
      expect(op_result.model.name).to eq(pool_name)
    end
  end

  context 'segmented pool creation' do
    let(:base_pool) { create(:pool) }
    let(:op_params) { { name: 'amazing pool', base_pool_id: base_pool.id, segments: { whatever: 'segment' } } }
    let(:users) { create_list(:user, 5) }

    before do
      # NOTE: Segment agnostic spec
      allow(SegmentsApply).to receive(:call).and_return fake_result
    end

    context 'when segments are applied successfully' do
      let(:fake_result) { OpenStruct.new("success?": true, model: segmented_users) }

      context 'with segment specified' do
        let(:segmented_users) { users.sample(1) }

        it 'returns successful result' do
          expect(op_result.success?).to eq true
          expect(op_result.model.system_generated?).to eq true
          expect(op_result.model.users.size).to eq(1)
        end
      end

      context 'without segments specified' do
        let(:segmented_users) { users }

        it 'returns successful result' do
          expect(op_result.success?).to eq true
          expect(op_result.model.system_generated?).to eq true
          expect(op_result.model.users.size).to eq(5)
        end
      end

      context 'when segment does not match any users' do
        let(:segmented_users) { [] }

        it 'returns successful result' do
          expect(op_result.success?).to eq true
          expect(op_result.model.system_generated?).to eq true
          expect(op_result.model.users.size).to eq(0)
        end
      end
    end

    context 'when SegmentsApply operation fails' do
      let(:fake_result) { OpenStruct.new("success?": false) }

      it 'fails the operation' do
        expect(op_result.success?).to eq false
        expect(op_result.errors[:users].first).to eq('Failed to apply segment')
      end
    end
  end

  # TODO: handle case where SegmentsApply operation fails
  # TODO: handle case where SegmentsApply count is zero -> should still create the pool
end
