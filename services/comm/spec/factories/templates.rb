# frozen_string_literal: true

FactoryBot.define do
  factory :template do
    content { Faker::ChuckNorris.fact }
    status { 'N/a' }

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
