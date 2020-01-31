# frozen_string_literal: true

FactoryBot.define do
  factory :public_key do
    association :user
  end
end
