# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SegmentsApply, type: :operation do
  let(:op_params) { { users: User.all, segments: {} } }
  let(:op_result) { described_class.call(op_params) }

  before do
    create_list(:user, 5)
  end

  it 'returns successfull result' do
    expect(op_result.success?).to eq true
    expect(op_result.model.size).to eq(5)
  end

  # TODO: cover case where multiple segments are passed and one of them fails
  # TODO: cover case where segment is inexistent (NameError raised)
end
