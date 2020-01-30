# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    header { Faker::Lorem.sentence }

    association :transfer_map
  end
end
