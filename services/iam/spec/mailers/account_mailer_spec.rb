# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountMailer, type: :mailer do
  describe 'team_welcome' do
    let(:base_url) { 'http://bananas.com' }
    let(:user) { create(:user) }
    let(:reset_password_token) { 'secret_token' }
    let(:mail) { described_class.team_welcome(user, reset_password_token) }
    let(:jwt) do
      Ros::Jwt.new(
        token: reset_password_token,
        account_id: Tenant.current_tenant&.alias,
        username: user.username
      ).encode(:confirmation)
    end

    let(:url) { "#{base_url}/password/new?reset_password_token=#{jwt}" }

    before do
      freeze_time
      # NOTE: Ensuring that the current tenant has the base url set
      Tenant.current_tenant.update(properties: { base_url: base_url })
      allow_any_instance_of(User).to receive(:set_reset_password_token).and_return(reset_password_token)
    end

    it 'has correct headers' do
      expect(mail.subject).to eq('Team welcome')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['no-reply@example.com'])
    end

    it 'has correct link in the body' do
      expect(mail.body.encoded).to include(url)
    end

    it 'delivers an email' do
      expect { mail.deliver }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
