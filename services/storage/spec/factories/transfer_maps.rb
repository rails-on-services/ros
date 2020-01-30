# frozen_string_literal: true

FactoryBot.define do
  factory :transfer_map do
    name { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
    service { Faker::Lorem.word }
    target { Faker::Lorem.word }
  end
end
