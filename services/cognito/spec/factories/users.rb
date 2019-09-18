# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    primary_identifier { SecureRandom.uuid }
    properties { '' }
  end
end
