# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Template, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:campaign) { create(:campaign) }
  end

  describe 'render' do
    let(:first_name) { 'Jim' }
    let(:title) { 'Mr.' }
    let(:primary_identifier) { 'random-123-primary-identifier' }
    let(:user) { create(:user, first_name: first_name, primary_identifier: primary_identifier, title: title) }

    context 'when valid keys are passed' do
      let(:template) { create(factory_name, content: 'Hi [userFirstName] [userId] [salutation]') }
      let(:valid_content) { "Hi #{first_name} #{primary_identifier} #{title}" }

      it 'renders valid content' do
        expect(template.render(user: user, campaign: campaign)).to eq valid_content
      end
    end

    context 'when invalid keys are passed' do
      let(:template) { create(factory_name, content: 'Hi [userFirstName] [userId] [salutationn]') }
      let(:invalid_content) { "Hi #{first_name} #{primary_identifier} [salutationn]" }

      it 'renders content with raw invalid key' do
        expect(template.render(user: user, campaign: campaign)).to eq invalid_content
      end
    end

    context 'when required arguments are nil' do
      let(:template_one)   { create(factory_name, content: 'Hi [userFirstName] [userId] [salutation]') }
      let(:template_two)   { create(factory_name, content: 'Hi [userFirstName] [userId]') }
      let(:template_three) { create(factory_name, content: 'This is your [campaignUrl]') }
      let(:template_four)  { create(factory_name, content: 'Hi [salutation] [userFirstName] this is your [campaignUrl]') }

      it 'renders content with the raw keys' do
        expect(template_one.render(user: nil, campaign: nil)).to eq template_one.content
        expect(template_two.render(user: nil, campaign: campaign)).to eq template_two.content
        expect(template_three.render(user: user, campaign: nil)).to eq template_three.content
        expect(template_four.render(user: user, campaign: nil)).to eq "Hi #{title} #{first_name} this is your [campaignUrl]"
      end
    end
  end
end
