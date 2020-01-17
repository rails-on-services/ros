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
        to: '+6512345678',
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
            to: '+6512345678',
            body: 'hello'
          },
          user: user,
          send_at: 10.minutes.from_now.to_s
        }
      end

      it 'enqueues the the message to be sent to the provider' do
        expect { op_result }.to have_enqueued_job(MessageSendJob)
      end
    end

    context 'when recipient id is provided' do
      let(:op_params) do
        {
          params: {
            provider_id: message_owner.provider_id,
            channel: 'sms',
            owner_type: message_owner.class.name,
            owner_id: message_owner.id,
            from: 'PerxTech',
            recipient_id: 1,
            body: 'hello'
          },
          user: user
        }
      end

      it 'saves the message with phone number of the recipient' do
        mocked_phone_number = '+6512345678'
        allow(Ros::Cognito::User).to receive(:find).and_return([OpenStruct.new(phone_number: mocked_phone_number, id: 1)])

        op_result

        expect(Message.first.to).to eq mocked_phone_number
      end
    end
  end

  context 'when provider is not given' do
    let(:op_params) do
      {
        params: {
          channel: 'sms',
          owner_type: message_owner.class.name,
          owner_id: message_owner.id,
          from: 'PerxTech',
          to: '+6512345678',
          body: 'hello'
        },
        user: user
      }
    end

    context 'with AWS provider setup' do
      it 'falls back to aws provider as default' do
        expect(op_result.success?).to eq true
        expect(op_result.model.provider.type).to eq 'Providers::Aws'
      end
    end

    context 'without AWS provider setup' do
      before do
        message_owner.provider.update!(type: 'Providers::Twilio')
      end

      it 'returns unsuccessful operation with error' do
        expect(op_result.success?).to eq false
        expect(op_result.errors.full_messages).to eq ['Provider must exist']
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
            to: '+6512345678',
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

    context 'when phone number and recipient id are missing' do
      let(:op_params) do
        {
          params: {
            provider_id: message_owner.provider_id,
            channel: 'sms',
            owner_type: message_owner.class.name,
            owner_id: message_owner.id,
            from: 'PerxTech',
            body: 'hello'
          },
          user: user
        }
      end

      it 'returns unsuccessful operation with error' do
        expect(op_result.success?).to eq false
        expect(op_result.errors.full_messages).to eq ['Recipient is missing']
      end
    end

    context 'when phone number and recipient id are not matched' do
      let(:op_params) do
        {
          params: {
            provider_id: message_owner.provider_id,
            channel: 'sms',
            owner_type: message_owner.class.name,
            owner_id: message_owner.id,
            from: 'PerxTech',
            to: '+6512345678',
            body: 'hello',
            recipient_id: 1
          },
          user: user
        }
      end

      before do
        allow(Ros::Cognito::User).to receive(:find).and_return([OpenStruct.new(phone_number: '+6511112222', id: 1)])
      end

      it 'returns unsuccessful operation with error' do
        expect(op_result.success?).to eq false
        expect(op_result.errors.full_messages).to eq ['Recipient mismatch']
      end
    end

    context 'when recipient id is not valid' do
      let(:op_params) do
        {
          params: {
            provider_id: message_owner.provider_id,
            channel: 'sms',
            owner_type: message_owner.class.name,
            owner_id: message_owner.id,
            from: 'PerxTech',
            body: 'hello',
            recipient_id: 1
          },
          user: user
        }
      end

      before do
        allow(Ros::Cognito::User).to receive(:find).and_raise(JsonApiClient::Errors::NotFound.new('record not found'))
      end

      it 'returns unsuccessful operation with error' do
        expect(op_result.success?).to eq false
        expect(op_result.errors.full_messages).to eq ['Recipient 1 cannot be found']
      end
    end
  end
end
