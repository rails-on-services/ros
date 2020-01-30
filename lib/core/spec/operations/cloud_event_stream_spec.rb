# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ros::CloudEventStream, type: :operation do
  let(:op_result) { described_class.call(type: 'something', message_id: 1, data: 'else') }

  context 'when everything is fine' do
    before do
      Settings.event_logging.enabled = true
      allow(Rails.configuration.x.event_logger).to receive(:log_event).and_return OpenStruct.new(success?: true)
    end

    it 'runs successfully' do
      expect(op_result.success?).to eq true
    end
  end

  context 'when everything is not so fine' do
    describe 'when log_event fails' do
      before do
        allow(Rails.configuration.x.event_logger).to receive(:log_event).and_return OpenStruct.new(
          'success?': false,
          reason_phrase: 'something goes not so well'
        )
      end

      it 'fails successfully and return an error' do
        expect(op_result.success?).to eq false
        expect(op_result.errors.first).to eq([:logger, 'something goes not so well'])
      end
    end

    describe 'when log_event fails' do
      before do
        allow(Rails.configuration.x.event_logger).to receive(:log_event).and_raise Faraday::Error.new(
          'something is broken'
        )
      end

      it 'fails successfully and return an error' do
        expect(op_result.success?).to eq false
        expect(op_result.errors.first).to eq([:logger, 'something is broken'])
      end
    end
  end
end
