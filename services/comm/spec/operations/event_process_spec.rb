# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:op_params) { { id: 1 } }
  let(:operation) { described_class.call(params: op_params) }
  let(:result) { OperationResult.new(*operation) }

  context 'when the event has been setup properly' do
    let(:users) { create_list :user, 5 }
    let!(:target) { stubbed_resource(resource: Ros::Cognito::Pool, attributes: OpenStruct.new(users: users)) }
    let!(:event) { create :event, target_type: 'Ros::Cognito::Pool', target_id: 1 }
    let(:op_params) { { id: event.id } }

    it 'runs successfully' do
      expect(result.success?).to eq true
    end

    it 'creates one message per user' do
      expect { result }.to change { Message.count }.by(users.length)
    end
  end

  context 'when event does not exist' do

  end
end
