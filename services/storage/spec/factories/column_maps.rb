# frozen_string_literal: true

FactoryBot.define do
  factory :column_map do
    association :transfer_map
    name { Faker::Lorem.word }
    user_name { Faker::Name.first_name }
  end
end
