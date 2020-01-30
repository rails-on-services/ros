# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    owner_type { Faker::Job.title }
    owner_id { SecureRandom.random_number(1_000_000) }
  end
end
