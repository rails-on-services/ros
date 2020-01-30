# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  include_examples 'application record concern'

  let(:unconfirmed_user) { create(:user, password: nil, confirmed_at: nil) }
  let(:confirmed_user) { create(:user) }

  # TODO: move this into a proper shared context
  before(:all) { ActiveJob::Base.queue_adapter = :test }

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to validate_presence_of(:username) }
  end

  context 'not confirmed' do
    let(:user) { unconfirmed_user }

    it 'sends an email for unconfirmed users' do
      expect do
        user.valid?
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it 'does not need a password' do
      expect(user.password_required?).to be false
      expect(user.valid?).to be true
    end
  end

  context 'confirmed' do
    let(:user) { confirmed_user }

    it 'must have a password' do
      expect(user.password_required?).to be true
      expect(user.valid?).to be true
    end
  end

  context 'password handling' do
    let(:user) { confirmed_user }

    it 'creates a job' do
      expect do
        user.send_reset_password_instructions
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
