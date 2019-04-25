# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    association :provider, factory: :provider_aws
    from { Faker::PhoneNumber.cell_phone }
    to { Faker::PhoneNumber.cell_phone }
    body { Faker::Lorem.paragraph }
    channel { 'sms' }
    association :owner, factory: :event
  end
end
