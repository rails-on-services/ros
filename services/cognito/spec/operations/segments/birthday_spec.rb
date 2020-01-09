# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Segments::Birthday, type: :operation do
  include ActiveSupport::Testing::TimeHelpers

  let(:op_params) { { segment: segment, users: User.all } }
  let(:op_result) { described_class.call(op_params) }

  before do
    # NOTE: Create 20yo users
    travel_to Time.zone.today.beginning_of_month - 20.years do
      create_list(:user, 2, birthday: Time.zone.today)
      create_list(:user, 3, birthday: Time.zone.today.end_of_month)
    end

    # NOTE: Travel back to this year
    travel_to Time.zone.today.beginning_of_month
  end

  context 'birthday this day' do
    let(:segment) { 'this_day' }

    it 'returns successful result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(2)
    end
  end

  context 'birthday this month' do
    let(:segment) { 'this_month' }

    it 'returns successful result' do
      expect(op_result.success?).to be_truthy
      expect(op_result.model.size).to eq(5)
    end
  end

  context 'wrong segment value' do
    let(:segment) { 'wrong_walue' }

    it 'returns unsuccessful result' do
      expect(op_result.success?).to be_falsey
    end
  end
end
