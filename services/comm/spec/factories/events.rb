# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    send_at { Time.zone.now + 10.minutes }
    channel { 'weblink' }
    sequence(:owner_id)
    owner_type { 'Perx::Campaign::Entity' }
    association :provider, factory: :provider_aws
    association :campaign
    template
    sequence(:target_id)
    target_type { 'Ros::Cognito::Pool' }

    # trait :within_schema do
    #   transient do
    #     schema { 'public' }
    #   end

    #   before(:create) do |_entity, evaluator|
    #     Apartment::Tenant.switch! evaluator.schema
    #   end

    #   after(:create) do
    #     Apartment::Tenant.reset
    #   end
    # end
  end
end
