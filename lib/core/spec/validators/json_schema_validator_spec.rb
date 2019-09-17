# frozen_string_literal: true

require 'rails_helper'

class Validatable
  include ActiveRecord::Validations
  SCHEMA = Rails.root.join('spec', 'schemas', 'validatable.json')
  attr_accessor :properties

  validates :properties, json_schema: { schema: SCHEMA }
end

describe JsonSchemaValidator do
  let(:properties) { {} }
  subject { Validatable.new(properties: properties) }

  describe 'when attribute respects the schema' do
    let(:properties) do
      {
        title: 'TITLE',
        button: 'BUTTON',
        closed_pinata_img_url: 'url',
        no_of_taps: 10
      }
    end

    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  # context 'without provider' do
  #   it 'is valid' do
  #     expect(subject).to be_valid
  #   end
  # end

  # context 'with valid provider' do
  #   it 'is valid' do
  #     subject.stubs(omniauth_provider: 'facebook')

  #     expect(subject).to be_valid
  #   end
  # end

  # context 'with unused provider' do
  #   it 'is invalid' do
  #     subject.stubs(omniauth_provider: 'twitter')

  #     expect(subject).not_to be_valid
  #     expect(subject).to have(1).error_on(:omniauth_provider)
  #   end
  # end
end
