# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcess, type: :operation do
  let(:op_result) { described_class.call(params: {}) }

  before do
    allow(MessageCreate).to receive(:call).and_return(true)
  end

  it 'works' do
    expect(op_result.success?).to eq(true)
  end
end
