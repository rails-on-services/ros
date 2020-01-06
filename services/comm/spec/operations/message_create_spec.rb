# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageCreate, type: :operation do
  let(:op_result) { described_class.call(op_params) }
  let(:iam_user) { create :iam_user }
  let(:cognito_user_id) { nil }
  let(:user) { PolicyUser.new(iam_user, cognito_user_id) }
  # NOTE: an event needs a valid target
  let!(:target) { stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new) }
  # TODO: Who should be the owner of a message?
  let!(:message_owner) { create :event }
  let(:op_params) do
    {
      params: {
        provider_id: message_owner.provider_id,
        channel: 'sms',
        owner_type: message_owner.class.name,
        owner_id: message_owner.id,
        from: 'PerxTech',
        to: '+6587173612',
        body: 'hello'
      },
      user: user
    }
  end

  before do
    allow_any_instance_of(Providers::Aws).to receive(:sms).and_return true
  end

  context 'when all attributes are valid' do
    it 'returns successful operation' do
      expect(op_result.success?).to eq true
    end

    it 'creates the message' do
      expect { op_result }.to change { Message.count }.by(1)
    end

    context 'when send_at is nil' do
      before do
        allow(MessageSendJob).to receive(:perform_now).and_return true
        op_result
      end
      it 'sends the message to the provider' do
        expect(MessageSendJob).to have_received(:perform_now).once
      end
    end

    context 'when send_at is a date time' do
      let(:op_params) do
        {
          params: {
            provider_id: message_owner.provider_id,
            channel: 'sms',
            owner_type: message_owner.class.name,
            owner_id: message_owner.id,
            from: 'PerxTech',
            to: '+6587173612',
            body: 'hello'
          },
          user: user,
          send_at: 10.minutes.from_now.to_s
        }
      end

      it 'enqueues the the message to be sent to the provider' do
        expect { op_result }.to have_enqueued_job
      end
    end
  end

  context 'when send_at is not a date time' do
    let(:op_params) do
      {
        params: {
          provider_id: message_owner.provider_id,
          channel: 'sms',
          owner_type: message_owner.class.name,
          owner_id: message_owner.id,
          from: 'PerxTech',
          to: '+6587173612',
          body: 'hello'
        },
        user: user,
        send_at: 'bananas'
      }
    end

    it 'returns unsuccessful operation with error' do
      expect(op_result.success?).to eq false
      expect(op_result.errors.full_messages).to eq ['Send at is not a valid date format (send_at: bananas)']
    end

    it 'does not create the message' do
      expect { op_result }.to_not(change { Message.count })
    end
  end
end
