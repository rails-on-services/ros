# frozen_string_literal: true

FactoryBot.define do
  factory :org do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    properties { {} }
  end
end
