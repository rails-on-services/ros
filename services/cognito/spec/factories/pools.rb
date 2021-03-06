# frozen_string_literal: true

FactoryBot.define do
  factory :pool do
    sequence(:name) { |n| "Pool-#{n}-Name" }
    properties { '' }
  end
end
