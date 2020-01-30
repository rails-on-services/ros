# frozen_string_literal: true

FactoryBot.define do
  factory :template do
    name { Faker::Company.name }
    content { Faker::ChuckNorris.fact }
    status { 'N/a' }
    description { Faker::Lorem.paragraph }

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
