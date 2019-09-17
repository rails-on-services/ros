# frozen_string_literal: true

FactoryBot.define do
  factory :root do
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    trait :with_tenant do
      after(:create) do |root, _|
        FactoryBot.create(:tenant, root: root)
      end
    end
  end
end
