# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenantPolicy, type: :policy do
  context 'when user is root' do
    let(:user) { double('user', root?: true) }
    subject { described_class.new(user, {}) }

    it 'allows user to create a new tenant' do
      expect(subject.create?).to eq true
    end
  end

  context 'when user is not root' do
    let(:user) { double('user', root?: false) }
    subject { described_class.new(user, {}) }

    it 'does not allows user to create a new tenant' do
      expect(subject.create?).to eq false
    end
  end
end
