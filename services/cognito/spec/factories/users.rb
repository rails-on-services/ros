FactoryBot.define do
  factory :user do
    primary_identifier { SecureRandom.uuid }
    properties { "" }
    phone { Faker::PhoneNumber.cell_phone }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }

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
