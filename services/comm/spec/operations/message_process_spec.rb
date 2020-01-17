# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcess, type: :operation do
  let(:op_result) { described_class.call(params: {}) }
  let(:errors) { OpenStruct.new(full_messages: ['something wrong']) }

  before do
    allow(MessageCreate).to receive(:call).and_return(OpenStruct.new(success?: success, errors: errors))
  end

  context 'when everything fine' do
    let(:success) { true }
    it 'works' do
      expect(op_result.success?).to eq(true)
    end
  end

  context 'when something wrong' do
    let(:success) { false }
    it 'fails with error message' do
      expect(op_result.success?).to eq(false)
      expect(op_result.errors.full_messages).to match_array(['Message something wrong'])
    end
  end
end
