# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SegmentsApply, type: :operation do
  let(:op_params) { {users: [], segments: {}} }
  let(:op_result) { described_class.call(op_params) }

  it 'returns successfull result' do
    expect(op_result.success?).to be_truthy
  end
end
