# frozen_string_literal: true

FactoryBot.define do
  factory :credential do
    for_root

    trait :for_user do
      association(:owner, factory: :user)
    end

    trait :for_root do
      association(:owner, factory: %i[root with_tenant])
    end
  end
end
