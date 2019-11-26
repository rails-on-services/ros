# frozen_string_literal: true

FactoryBot.define do
  factory :policy do
    name { Faker::Internet.username }

    trait :administrator_access do
      name { 'AdministratorAccess' }
    end

    trait :readonly_access do
      name { 'IamUserReadOnlyAccess'}
    end

    trait :readwrite_access do
      name { 'IamUserFullAccess'}
    end
  end
end
