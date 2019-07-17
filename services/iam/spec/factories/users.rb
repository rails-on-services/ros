# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    password { Faker::Internet.password }
    console { true }
    api { true }

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
# TODO: Move to Cognito
# first_name { Faker::Name.first_name }
# last_name { Faker::Name.last_name }
# gender { ['Male', 'Female'].sample }
# salutation { ['Mr', 'Ms', 'Dr'].sample }
# phone '+6500000000'
# identifier { Faker::Number.hexadecimal(10) }
# state { :active }
# properties { { alternate_id: Faker::Number.hexadecimal(7) } }

# factory :active_user do
#   state 'active'
# end

# factory :inactive_user do
#   state 'inactive'
# end
