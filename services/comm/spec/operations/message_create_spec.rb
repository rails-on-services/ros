# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageCreate, type: :operation do
  let(:operation) { described_class.call(params: op_params) }
  let(:result) { OperationResult.new(*operation) }
  # TODO: Who should be the owner of a message?
  let!(:message_owner) { create :event }
  let(:op_params) do
    {
      provider_id: message_owner.provider.id,
      channel: 'sms',
      owner_type: message_owner.class.name,
      owner_id: message_owner.id,
      from: 'PerxTech',
      to: '+6587173612',
      body: 'hello'
    }
  end

  context 'when all attributes are valid' do
    it 'returns successful operation' do
      expect(result.success?).to eq true
    end

    it 'creates the message' do
      expect { result }.to change { Message.count }.by(1)
    end

    xcontext 'when send_at is nil' do
      it 'sends the message to the provider' do
        expect()
      end
    end

    xcontext 'when send_at is a date time' do
      it 'enqueues the the message to be sent to the provider' do
      end
    end
  end

  xcontext 'when some attributes are not valid' do
    it 'returns unsuccessful operation with error' do
      expect(result.success?).to eq false
      expect(result.errors.full_messages).to eq ['Send at is invalid']
    end

    it 'does not create the message' do
      expect { result }.to_not(change { Message.count })
    end

    context 'when send_at is not a date time' do
      it 'returns unsuccessful operation with error' do
        expect(result.success?).to eq false
        expect(result.errors.full_messages).to eq ['Send at is not a valid date format (send_at: bananas)']
      end

      it 'does not create the message' do
        expect { result }.to_not(change { Message.count })
      end
    end
  end
end
