# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    send_at { Time.zone.now + 10.minutes }
    channel { 'sms' }
    campaign_entity_id { 10 }
    template
    association :provider, factory: :provider_aws

    trait :within_schema do
      transient do
        schema { 'public' }
      end

      before(:create) do |_entity, evaluator|
        Apartment::Tenant.switch! evaluator.schema
      end

      after(:create) do
        Apartment::Tenant.reset
      end
    end
  end
end
