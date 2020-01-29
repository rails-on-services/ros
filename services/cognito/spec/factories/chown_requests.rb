# frozen_string_literal: true

FactoryBot.define do
  factory :chown_request do
    to_id { SecureRandom.random_number(1_000_000) }
    from_ids { [SecureRandom.random_number(1_000_000)] }
  end
end
