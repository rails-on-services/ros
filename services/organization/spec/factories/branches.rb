# frozen_string_literal: true

FactoryBot.define do
  factory :branch do
    name { Faker::Company.name }
    properties { {} }
    org
  end
end
