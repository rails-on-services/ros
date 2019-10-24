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
      from_urn = Ros::Urn.from_urn(urn)
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
  end

  context 'instance methods' do
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
