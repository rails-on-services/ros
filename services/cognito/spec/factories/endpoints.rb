# frozen_string_literal: true

FactoryBot.define do
  factory :endpoint do
    url { Faker::Internet.url }
    target_type { 'Perx::Survey::Campaign' }
    target_id { SecureRandom.random_number(1_000_000) }
    properties { {} }
  end
end
