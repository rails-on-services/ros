# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe TransferMap, type: :model do
  let(:temp_csv_file) do
    CSV.parse(<<~ROWS)
      Name,Department,Salary
      Bob,Engineering,1000
      Jane,Sales,2000
      John,Management,5000
    ROWS
  end

  it 'can parse csv file headers' do
    expect(temp_csv_file[0]).to eq(%w[Name Department Salary])
  end

  let(:file_fingerprint) { double(where: [{ 'model_columns' => ['doesntcare'] }]) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:service) }
    it { is_expected.to validate_presence_of(:target) }

    it 'validates service name and the target' do
      stub_const 'Ros::Whatever::FileFingerprint', file_fingerprint
      transfer_map = TransferMap.create(name: 'test transfer map', service: 'whatever', target: 'doesntcare')
      expect(transfer_map).to be_valid
    end
  end

  it 'can be created' do
    stub_const 'Ros::Whatever::FileFingerprint', file_fingerprint
    transfer_map = TransferMap.create(name: 'test transfer map', service: 'whatever', target: 'doesntcare')

    expect(TransferMap.find(transfer_map.id)).to eq(transfer_map)
  end
end
