# frozen_string_literal: true

FactoryBot.define do
  factory :metabase_card do
    card_id { SecureRandom.random_number(1_000_000) }
    identifier { Faker::Internet.username }
  end
end
