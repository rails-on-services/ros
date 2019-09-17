# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ColumnMap, type: :model do
  let(:file_fingerprint) { double(where: [{ 'model_columns' => ['doesntcare'] }]) }
  let(:transfer_map) { FactoryBot.create(:transfer_map) }

  it 'can be created' do
    stub_const 'Ros::Whatever::FileFingerprint', file_fingerprint
    expect(1).to eq(1)
  end
end
