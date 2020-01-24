# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageSend, type: :operation do
  let(:op_result) { described_class.call(op_params) }
  let!(:public_tenant) { create(:tenant, schema_name: 'public') }

  before do
    allow_any_instance_of(Providers::Aws).to receive(:sms).and_return true
  end

  context 'when message is sent' do
    let(:provider) { create(:provider_aws, default_for: ['sms']) }
    let(:message) { create(:message, provider_id: nil) }
    let(:op_params) { { id: message.id } }

    context 'with message provider' do
      let(:message) { create(:message) }

      it 'works' do
        expect(op_result.success?).to eq true
      end
    end

    context 'with tenant provider' do
      before { provider }

      it 'works' do
        expect(op_result.success?).to eq true
      end
    end

    context 'with platform provider' do
      before { Apartment::Tenant.switch('public') { provider } }

      it 'works' do
        expect(op_result.success?).to eq true
      end
    end
  end

  context 'when message sending failed' do
    let(:op_params) { { id: rand(100..500) } }

    it 'throws errors' do
      expect(op_result.errors.size).to be_positive
    end
  end
end
