# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    send_at { 10.minutes.from_now }
    channel { 'sms' }
    campaign
    template
    association :provider, factory: :provider_aws
  end
end
