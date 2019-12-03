# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:op_result) { described_class.call(params: op_params) }

  before do
    allow(MessageCreate).to receive(:call).and_return true
  end

  context 'when the event has been setup properly' do
    let(:users) { create_list :user, 50 }
    let!(:target) { stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new(users: users)) }
    let!(:event) { create :event }
    let(:op_params) { { id: event.id } }

    it 'runs successfully' do
      expect(op_result.success?).to eq true
    end

    it 'has an event and template attached, and status changed to published' do
      ctx = op_result.instance_variable_get :@ctx
      expect(ctx[:event]).not_to be_nil
      expect(ctx[:template]).not_to be_nil
      expect(ctx[:event][:status]).to eq('published')
    end

    it 'creates one message per user' do
      op_result
      # TODO: Check that params are passed properly
      expect(MessageCreate).to have_received(:call).exactly(users.length).times
    end
  end

  context 'when event does not exist' do
    let(:op_params) { { id: 1000 } }

    it 'fails the operation' do
      expect(op_result.success?).to eq false
      expect(op_result.errors.full_messages).to eq ['Event not found for tenant (params: {:id=>1000})']
    end

    it 'does not create messages for any users' do
      op_result
      expect(MessageCreate).to_not have_received(:call)
    end
  end
end
