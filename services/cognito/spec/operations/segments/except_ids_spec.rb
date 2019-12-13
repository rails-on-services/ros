# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segments::ExceptIds, type: :operation do
  let(:users) { create_list(:user, 5) }
  let(:op_params) { { segment: segment, users: User.all } }
  let(:op_result) { described_class.call(op_params) }

  let(:segment) { users.sample(3).pluck(:id) }

  it 'returns successfull result' do
    expect(op_result.success?).to be_truthy
    expect(op_result.model.size).to eq(2)
  end
end
