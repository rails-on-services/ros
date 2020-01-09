# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segments::Age, type: :operation do
  let(:op_params) { { segment: segment, users: User.all } }
  let(:op_result) { described_class.call(op_params) }

  before do
    [16, 19, 20, 21, 32, 35, 64].each do |age|
      create(:user, with_age: age)
    end
  end

  context 'specific age' do
    let(:segment) { 21 }

    it 'returns successful result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(1)
    end
  end

  context 'age range' do
    let(:segment) { { from: 18, to: 21 } }

    it 'returns successful result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(3)
    end
  end

  context 'age array' do
    let(:segment) { [16, 32, 64, 70] }

    it 'returns successful result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(3)
    end
  end

  context 'age combined array' do
    let(:segment) do
      [
        { from: 18, to: 21 },
        { from: 30, to: 40 },
        64
      ]
    end

    it 'returns successful result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(6)
    end
  end
end
