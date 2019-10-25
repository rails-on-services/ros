# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:operation) { described_class.call(params: op_params) }
  let(:result) { Ros::OperationResult.new(*operation) }

  before do
    allow(MessageCreate).to receive(:call).and_return true
  end

  context 'when the event has been setup properly' do
    let(:users) { create_list :user, 5 }
    let!(:target) { stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new(users: users)) }
    let!(:event) { create :event }
    let(:op_params) { { id: event.id } }

    it 'runs successfully' do
      expect(result.success?).to eq true
    end

    it 'creates one message per user' do
      result
      # TODO: Check that params are passed properly
      expect(MessageCreate).to have_received(:call).exactly(users.length).times
    end
  end

  context 'when event does not exist' do
    let(:op_params) { { id: 1000 } }

    it 'fails the operation' do
      expect(result.success?).to eq false
      expect(result.errors.full_messages).to eq ['Event not found for tenant (params: {:id=>1000})']
    end

    it 'does not create messages for any users' do
      result
      expect(MessageCreate).to_not have_received(:call)
    end
  end
end
