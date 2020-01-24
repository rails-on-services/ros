# frozen_string_literal: true

FactoryBot.define do
  factory :provider_aws, class: 'Providers::Aws' do
    name { 'AWS' }
    access_key_id { 'access_key_id' }
    secret_access_key { 'secret_access_key' }
    channels { ['sms'] }
  end

  factory :provider_twilio, class: 'Providers::Twilio' do
    name { 'Twilio' }
    account_sid { 'sid' }
    auth_token { 'token' }
    channels { %w[sms call] }
  end
end
