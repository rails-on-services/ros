# frozen_string_literal: true

FactoryBot.define do
  factory :metabase_card do
    card_id { rand(1..1000) }
    identifier { Faker::Internet.username }
  end
end
