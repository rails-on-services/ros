# frozen_string_literal: true

FactoryBot.define do
  factory :tenant do
    properties { {} }
    schema_name { rand(100_000_000..999_999_999).to_s.scan(/.{3}/).join('_') }
    root
  end
end
