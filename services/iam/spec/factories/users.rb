# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    password { Faker::Internet.password }
    email { Faker::Internet.email }
    confirmed_at { DateTime.now }
    console { true }
    api { true }

    trait :administrator_access do
      policies { [create(:policy, :administrator_access)] }
    end

    trait :within_schema do
      transient do
        schema { 'public' }
      end

      before(:create) do |_user, evaluator|
        Apartment::Tenant.switch! evaluator.schema
      end

      after(:create) do
        Apartment::Tenant.reset
      end
    end
  end
end
