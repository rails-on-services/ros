# frozen_string_literal: true

FactoryBot.define do
  factory :policy do
    name { Faker::Internet.username }
  end
end
