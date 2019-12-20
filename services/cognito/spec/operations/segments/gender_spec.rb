# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segments::Gender, type: :operation do
  let(:op_params) { { segment: segment, users: User.all } }
  let(:op_result) { described_class.call(op_params) }

  before do
    create(:user, gender: 'male')
    create(:user, gender: 'female')
    create(:user, gender: 'other')
  end

  context 'specific gender' do
    let(:segment) { 'male' }

    it 'returns successfull result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(1)
    end
  end

  context 'any gender' do
    let(:segment) { 'any' }

    it 'returns successfull result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(3)
    end
  end

  context 'several genders' do
    let(:segment) { %w[male other] }

    it 'returns successfull result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(2)
    end
  end
end
