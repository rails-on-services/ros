# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserCreate, type: :operation do
  ActiveJob::Base.queue_adapter = :test

  let(:username) { Faker::Internet.username }
  let(:email) { Faker::Internet.email }
  let(:policy_user) { double(PolicyUser, root?: true) }
  let(:op_params) { { email: email, username: username } }
  let(:op_result) { described_class.call(params: op_params, user: policy_user) }

  it 'works' do
    expect { op_result }.to have_enqueued_job(ActionMailer::MailDeliveryJob).on_queue('mailers').once
    expect(op_result.success?).to be_truthy
  end
end
