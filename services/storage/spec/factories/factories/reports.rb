# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    description { Faker::Lorem.paragraph }
  end
end
