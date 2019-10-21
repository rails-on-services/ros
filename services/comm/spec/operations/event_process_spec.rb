# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcess, type: :operation do
  let(:op_params) { { id: 1 } }
  let(:operation) { described_class.call(params: op_params) }
  let(:result) { Result.new(*operation) }

  context 'when the event has been setup properly' do
    let!(:event) { create :event }
    let(:op_params) { { id: event.id } }

    it 'runs successfully' do
      expect(result.success?).to eq true
    end
  end
end
