# frozen_string_literal: true

require 'rails_helper'

class Validatable
  include ActiveModel::Validations

  SCHEMA = Pathname.new("#{File.expand_path(File.dirname(__FILE__))}/schemas/validatable.json")
  attr_accessor :properties

  validates :properties, json_schema: { schema: SCHEMA }
end

describe JsonSchemaValidator do
  let(:properties) { {} }

  subject { Validatable.new }

  context 'when attribute respects the schema' do
    let(:properties) do
      {
        'title' => 'TITLE',
        'button' => 'BUTTON',
        'closed_pinata_img_url' => 'url',
        'no_of_taps' => 10
      }
    end

    it 'is valid' do
      subject.properties = properties
      expect(subject).to be_valid
    end
  end

  context 'when attribute does not respect the schema' do
    it 'is invalid when title is missing' do
      subject.properties = {
        'button' => 'BUTTON',
        'closed_pinata_img_url' => 'url',
        'no_of_taps' => 10
      }

      expect(subject).to be_invalid
      expect(subject.errors.messages[:properties].first).to eq 'JSON schema mismatched'
    end

    it 'is invalid when button is missing' do
      subject.properties = {
        'title' => 'TITLE',
        'closed_pinata_img_url' => 'url',
        'no_of_taps' => 10
      }

      expect(subject).to be_invalid
      expect(subject.errors.messages[:properties].first).to eq 'JSON schema mismatched'
    end

    it 'is invalid when button is closed_pinata_img_url is missing' do
      subject.properties = {
        'title' => 'TITLE',
        'button' => 'BUTTON',
        'no_of_taps' => 10
      }

      expect(subject).to be_invalid
      expect(subject.errors.messages[:properties].first).to eq 'JSON schema mismatched'
    end

    it 'is invalid when button is no_of_taps is missing' do
      subject.properties = {
        'title' => 'TITLE',
        'button' => 'BUTTON',
        'closed_pinata_img_url' => 'url',
      }

      expect(subject).to be_invalid
      expect(subject.errors.messages[:properties].first).to eq 'JSON schema mismatched'
    end
  end
end
