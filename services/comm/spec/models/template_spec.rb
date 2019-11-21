# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Template, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let!(:first_name) { 'Jim' }
    let!(:title) { 'Mr.' }
    let!(:primary_identifier) { 'random-123-primary-identifier' }
    let!(:user) { create(:user, first_name: first_name, primary_identifier: primary_identifier, title: title) }
    let!(:campaign) { create(:campaign) }
  end

  describe 'render' do
    context 'when valid keys are passed' do
      let(:template) { create(factory_name, content: 'Hi [userFirstName] [userId] [salutation]') }
      let(:valid_content) { "Hi #{first_name} #{primary_identifier} #{title}" }

      it 'renders valid content' do
        expect(template.render(user, campaign)).to eq valid_content
      end
    end

    context 'when invalid keys are passed' do
      let(:template) { create(factory_name, content: 'Hi [userFirstName] [userId] [salutationn]') }
      let(:invalid_content) { "Hi #{first_name} #{primary_identifier} salutationn"}

      it 'renders content with raw invalid key' do
        expect(template.render(user, campaign)).to eq invalid_content
      end
    end

    context 'when any of the arguments passed are nil' do
      let(:template) { create(factory_name, content: 'Hi [userFirstName] [userId] [salutation]') }

      it 'renders the original content when user is nil' do
        expect(template.render(nil, campaign)).to eq template.content
      end

      it 'renders the original content when campaign is nil' do
        expect(template.render(user, nil)).to eq template.content
      end

      it 'renders the original content when both user and campaign' do
        expect(template.render(nil, nil)).to eq template.content
      end
    end
  end
end
