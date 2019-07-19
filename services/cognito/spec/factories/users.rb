FactoryBot.define do
  factory :user do
    primary_identifier { SecureRandom.uuid }
    properties { "" }
    phone_number { Faker::PhoneNumber.cell_phone }

    trait :within_schema do
      transient do
        schema { 'public' }
      end

      before(:create) do |user, evaluator|
        Apartment::Tenant.switch! evaluator.schema
      end

      after(:create) do
        Apartment::Tenant.reset
      end
    end
  end
end
