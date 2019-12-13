# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:op_result) { described_class.call(op_params) }
  let(:users) { create_list :user, 5 }
  let(:event) { create(:event) }

  before do
    allow(MessageCreate).to receive(:call).and_return true
    stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new(users: users))
  end

  context 'when the event has been setup properly' do
    let(:op_params) { { id: event.id } }

    before do
      event
      op_result
    end

    it 'runs successfully' do
      expect(op_result.success?).to eq true
    end

    it 'changes event status to published' do
      expect(event.reload.status).to eq 'published'
    end

    xit 'creates one message per user' do
      op_result
      # TODO: Check that params are passed properly
      expect(MessageCreate).to have_received(:call).exactly(users.length).times
    end
  end

  context 'when event does not exist' do
    let(:op_params) { { id: 1000 } }

    it 'fails the operation' do
      expect(op_result.success?).to eq false
      expect(op_result.errors.full_messages).to eq ['Event not found for tenant (id: 1000)']
    end

    it 'does not create messages for any users' do
      op_result
      expect(MessageCreate).to_not have_received(:call)
    end
  end
end
