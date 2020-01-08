# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ros::Urn do
  let(:urn) { 'urn:ros:campaign::222222222:entity/1' }
  let(:urn_object) { Ros::Urn.new(*urn.split(':')) }

  context 'class methods' do
    it 'responds to `from_urn`' do
      expect(described_class.respond_to?(:from_urn)).to be_truthy
    end

    it 'correctly parse `from_urn`' do
      from_urn = described_class.from_urn(urn)
      expect(from_urn.txt).to eq('urn')
      expect(from_urn.partition_name).to eq('ros')
      expect(from_urn.service_name).to eq('campaign')
      expect(from_urn.region).to eq('')
      expect(from_urn.account_id).to eq('222222222')
      expect(from_urn.resource).to eq('entity/1')
    end

    it 'responds to `from_jwt`' do
      expect(described_class.respond_to?(:from_jwt)).to be_truthy
    end

    context 'when decoding successfully' do
      it 'returns a new object' do
        allow_any_instance_of(Ros::Jwt).to receive(:decode).and_return('sub' => 'urn:ros:campaign::1:entity/1')

        expect(described_class.from_jwt('token')).to be_an_instance_of(described_class)
      end
    end

    context 'when decoding returns an empty hash' do
      it 'returns nil' do
        allow_any_instance_of(Ros::Jwt).to receive(:decode).and_return({})

        expect(described_class.from_jwt('token')).to be_nil
      end
    end

    context 'when an error occurs while decoding' do
      it 'returns nil' do
        allow_any_instance_of(Ros::Jwt).to receive(:decode).and_raise(JWT::DecodeError)

        expect(described_class.from_jwt('token')).to be_nil
      end
    end
  end

  context 'instance methods' do
    subject { described_class.new('urn', 'ros', 'campaign', 1, 'entity/1', 'xxx') }

    it 'returns correct txt' do
      expect(subject.txt).to eq 'urn'
    end

    it 'returns correct partition_name' do
      expect(subject.partition_name).to eq 'ros'
    end

    it 'returns correct service_name' do
      expect(subject.service_name).to eq 'campaign'
    end

    it 'returns correct region' do
      expect(subject.region).to eq 1
    end

    it 'returns correct account_id' do
      expect(subject.account_id).to eq 'entity/1'
    end

    it 'returns correct account_id' do
      expect(subject.resource).to eq 'xxx'
    end

    it 'returns correct resource_type' do
      expect(urn_object.respond_to?(:resource_type)).to be_truthy
      expect(urn_object.resource_type).to eq('entity')
    end

    it 'returns correct resource_id' do
      expect(urn_object.respond_to?(:resource_id)).to be_truthy
      expect(urn_object.resource_id).to eq('1')
    end

    it 'returns correct model_name' do
      expect(urn_object.respond_to?(:model_name)).to be_truthy
      expect(urn_object.model_name).to eq('Entity')
    end
  end
end
