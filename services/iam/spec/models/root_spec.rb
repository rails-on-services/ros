# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Root, type: :model do
  context 'without tenant' do
    subject { create(:root) }

    it 'returns nil' do
      expect(subject.to_urn).to "urn:ros:iam::0:root/#{subject.id}"
    end
  end

  context 'with tenant' do
    subject { create(:root, :with_tenant) }

    it 'returns urn' do
      expectation = "#{described_class.urn_base}:#{subject.tenant.account_id}:root/#{subject.id}"

      expect(subject.to_urn).to eq expectation
    end
  end
end
