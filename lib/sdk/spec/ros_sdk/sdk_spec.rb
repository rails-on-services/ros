# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ros::Sdk::Credential do
  context 'when setting configure' do
    before do
      described_class.configure(access_key_id: 'secret', secret_access_key: 'another secret')
    end

    it 'sets access key correctly' do
      expect(described_class.access_key_id).to eq 'secret'
    end

    it 'stores secret access key correctly' do
      expect(described_class.secret_access_key).to eq 'another secret'
    end
  end

  context 'when setting request headers' do
    before do
      described_class.request_headers = { some: 'headers', goes: 'here' }
    end

    it 'sets request headers correctly' do
      expect(described_class.request_headers).to eq(some: 'headers', goes: 'here')
    end

    it 'stores request headers in RequestStore' do
      expect(::RequestStore.store[:request_headers]).to eq described_class.request_headers
    end
  end

  context 'when setting partition' do
    before do
      described_class.partition = 'anything'
    end

    it 'sets partition correctly' do
      expect(described_class.partition).to eq 'anything'
    end

    it 'stores partition in RequestStore' do
      expect(::RequestStore.store[:partition]).to eq described_class.partition
    end
  end

  context 'when setting authorization' do
    before do
      described_class.authorization = 'anything'
    end

    it 'sets authorization correctly' do
      expect(described_class.authorization).to eq 'anything'
    end

    it 'stores authorization in RequestStore' do
      expect(::RequestStore.store[:authorization]).to eq described_class.authorization
    end
  end
end
