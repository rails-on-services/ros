# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageSend, type: :operation do
  let(:op_result) { described_class.call(op_params) }
  let(:target)    { stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new) }
  let(:message)   { create(:message) }

  context 'when message is sent' do
    let(:op_params) { { id: message.id } }

    before do
      allow_any_instance_of(Providers::Aws).to receive(:sms).and_return true
      target
      op_result
    end

    it 'does not throw errors' do
      expect(op_result.errors.size).to eq 0
    end
  end

  context 'when message sending failed' do
    let(:op_params) { { id: rand(100..500) } }

    before do
      allow_any_instance_of(Providers::Aws).to receive(:sms).and_return true
      target
      op_result
    end

    it 'throws errors' do
      expect(op_result.errors.size).to be_positive
    end
  end
end
