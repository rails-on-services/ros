# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:op_params) { { id: 1 } }
  let(:operation) { described_class.call(params: op_params) }
  let(:result) { Result.new(*operation) }

  context 'when the event has been setup properly' do
    let(:event) { create :event, target_id: 1, target_type: 'Ros::Cognito::Pool' }
    let(:op_params) { { id: event.id } }
    let(:users) { create_list :user, 5 }

    before do
      # TODO: Figure out how to mock the results of the users
      stub_resource(model: Event, resource: :target, attributes: {})

      fake_query = double(Ros::Cognito::Pool, find: [OpenStruct.new(users: users)])
      allow(Ros::Cognito::Pool).to receive(:includes).and_return fake_query
      event
    end

    it 'runs successfully' do
      expect(result.success?).to eq true
    end

    # TODO: This is dependent on the mock to be defined in the before block
    it 'creates one message per user' do
      expect { result }.to change { Message.count }.by(users.length)
    end
  end
end
