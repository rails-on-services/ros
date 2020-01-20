# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:op_result) { described_class.call(op_params) }
  let(:users) { create_list(:user, 5) }
  let(:event) { create(:event) }

  before do
    stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new(users: users))
  end

  context 'when the event has been setup properly' do
    let(:op_params) { { id: event.id } }

    it 'runs successfully' do
      expect(op_result.success?).to eq true
    end

    it 'changes event status to published' do
      op_result
      expect(event.reload.status).to eq 'published'
    end

    it 'enqueued one message per user' do
      expect { op_result }.to have_enqueued_job(MessageProcessJob).exactly(users.length).times
    end
  end

  context 'when event does not exist' do
    let(:op_params) { { id: 1000 } }

    it 'fails the operation' do
      expect(op_result.success?).to eq false
      expect(op_result.errors.full_messages).to eq ['Event not found for tenant (id: 1000)']
    end

    it 'does not create messages for any users' do
      expect { op_result }.not_to have_enqueued_job(MessageProcessJob)
    end
  end
end
