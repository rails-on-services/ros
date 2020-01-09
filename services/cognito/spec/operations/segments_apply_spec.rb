# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SegmentsApply, type: :operation do
  let(:op_result) { described_class.call(op_params) }
  let(:op_params) { { users: User.all, segments: segments } }
  let(:segments) { {} }

  before do
    create_list(:user, 5)
  end

  context 'no segments are passed' do
    it 'returns successful result' do
      expect(op_result.success?).to eq true
      expect(op_result.model.size).to eq(5)
    end
  end

  context 'multiple segments are sent as attribute' do
    context 'when one segment does not exist' do
      let(:segments) { { 'bananas': '10', 'gender': 'male' }.as_json }

      it 'returns failure result' do
        expect(op_result.failure?).to eq true
        expect(op_result.model).to eq nil
        expect(op_result.errors.full_messages).to eq ["Segment can't find segmentation class"]
      end
    end

    context 'when one segment fails to apply' do
      let(:segments) { { 'age': { 'from': '10', 'to': '15' }, 'gender': 'male' }.as_json }

      before do
        allow(Segments::Age).to receive(:call).and_return(OpenStruct.new("failure?": true))
      end

      it 'returns failure result' do
        expect(op_result.failure?).to eq true
        expect(op_result.model).to eq nil
        expect(op_result.errors.full_messages).to eq ["Segment can't find segmentation class"]
      end
    end
  end
end
