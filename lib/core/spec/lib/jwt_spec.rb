# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ros::Jwt do
  subject { described_class.new('Bearer something') }

  context 'when payload is a hash' do
    subject { described_class.new({}) }

    it 'sets default payload' do
      mock = double('mock', aud: 'aud', iss: 'iss', alg: 'alg')
      allow(Settings).to receive(:jwt).and_return(mock)

      expect(subject.claims[:iss]).to eq 'iss'
      expect(subject.claims[:aud]).to eq 'aud'
      expect(subject.claims[:iat]).to be_an_instance_of Integer
    end
  end

  context 'when payload is not a hash' do
    subject { described_class.new('Bearer something') }

    it 'sets value to the token' do
      expect(subject.token).to_not be_empty
    end

    it 'removes Bearer' do
      expect(subject.token).to eq 'something'
    end

    it 'does not set claims' do
      expect(subject.claims).to be_empty
    end
  end

  context 'when decoding successfully' do
    it 'assigns value to claims' do
      mock = double('mock', encryption_key: 'encryption_key', alg: 'alg')
      data = { key1: 'some value' }

      allow(Settings).to receive(:jwt).and_return(mock)
      allow(JWT).to receive(:decode).with('something', 'encryption_key', 'alg').and_return([data, { header: {} }])

      expect(subject.claims).to eq HashWithIndifferentAccess.new(data)
    end
  end

  context 'when an error occurs while decoding' do
    it 'assigns empty hash to claims' do
      allow(JWT).to receive(:decode).and_raise(JWT::DecodeError)

      expect(subject.claims).to eq HashWithIndifferentAccess.new
    end
  end

  context 'when encoding' do
    it 'returns encoded string' do
      expect(subject.encode).to be_an_instance_of String
    end
  end
end
